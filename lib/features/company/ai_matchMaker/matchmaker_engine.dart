// lib/features/ai_matchmaker/matchmaker_engine.dart
//
// Local, free, offline "AI" matcher. No network, no API key.
// Understands English + Arabic (+ Franco words that exist in the maps below).
// Pure Dart: no Firebase and no Flutter imports, so it is easy to unit test.

import 'dart:math' as math;

// ───────────────────────── Models ─────────────────────────

class MatchProject {
  const MatchProject({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.techStack = const [],
    this.licenseType = '',
    this.ownerName = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final num price;
  final List<String> techStack;
  final String licenseType; // turnkey | source | enterprise (or free text)
  final String ownerName;
  final DateTime? createdAt;
}

class QuickReply {
  const QuickReply(this.label, this.text);
  final String label; // what the chip shows
  final String text; // what is sent when tapped
}

class MatchQuery {
  const MatchQuery({
    this.concepts = const {},
    this.keywords = const {},
    this.techs = const {},
    this.minPrice,
    this.maxPrice,
  });

  final Set<String> concepts;
  final Set<String> keywords;
  final Set<String> techs;
  final num? minPrice;
  final num? maxPrice;

  bool get hasTopic =>
      concepts.isNotEmpty || keywords.isNotEmpty || techs.isNotEmpty;
  bool get hasPrice => minPrice != null || maxPrice != null;
}

class MatchHit {
  const MatchHit(
    this.project,
    this.relevance,
    this.reasons, {
    this.overBudget = false,
  });

  final MatchProject project;
  final double relevance; // 0..1 (0 means "not scored", e.g. newest list)
  final List<String> reasons;
  final bool overBudget;

  int get percent =>
      relevance <= 0 ? 0 : (relevance * 100).round().clamp(1, 99);
}

enum MatchStatus { results, noMatch, needMoreInfo, greeting }

class MatchOutcome {
  const MatchOutcome({
    required this.status,
    required this.query,
    this.hits = const [],
    this.total = 0,
    this.followUps = const [],
    this.fallback = const [],
    this.relaxed = false,
  });

  final MatchStatus status;
  final MatchQuery query;
  final List<MatchHit> hits; // top results
  final int total; // all matches before taking the top ones
  final List<QuickReply> followUps;
  final List<MatchHit> fallback; // shown when nothing matched
  final bool relaxed; // fallback = same topic without the new filters
}

class _Budget {
  const _Budget(this.min, this.max);
  final num? min;
  final num? max;
}

// ───────────────────────── Engine ─────────────────────────

class MatchEngine {
  MatchEngine._();

  static MatchOutcome run(
    String text,
    List<MatchProject> catalog, {
    MatchQuery? previous,
  }) {
    // "Show everything": drop the tech/price filters, keep the topic.
    if (previous != null &&
        previous.hasTopic &&
        RegExp(
          r'^\s*(show all|show everything|clear filters|الكل)\s*$',
        ).hasMatch(_norm(text))) {
      final q = MatchQuery(
        concepts: previous.concepts,
        keywords: previous.keywords,
      );
      final all = _search(q, catalog);
      if (all.isNotEmpty) {
        final top = all.take(3).toList();
        return MatchOutcome(
          status: MatchStatus.results,
          query: q,
          hits: top,
          total: all.length,
          followUps: _followUps(top, q),
        );
      }
    }

    final parsed = parse(text);

    if (!parsed.hasTopic && !parsed.hasPrice) {
      final toks = _tokens(_norm(text));
      final greet = toks.isNotEmpty && toks.every(_greetings.contains);
      return MatchOutcome(
        status: greet ? MatchStatus.greeting : MatchStatus.needMoreInfo,
        query: previous ?? parsed,
      );
    }

    final q = _merge(previous, parsed);
    final hits = _search(q, catalog);

    if (hits.isNotEmpty) {
      final top = hits.take(3).toList();
      return MatchOutcome(
        status: MatchStatus.results,
        query: q,
        hits: top,
        total: hits.length,
        followUps: _followUps(top, q),
      );
    }

    // Nothing matched. If it was a refinement, show the pre-filter results.
    if (previous != null && !identical(q, parsed)) {
      final base = _search(previous, catalog);
      if (base.isNotEmpty) {
        return MatchOutcome(
          status: MatchStatus.noMatch,
          query: previous,
          fallback: base.take(3).toList(),
          relaxed: true,
        );
      }
    }

    // Otherwise show the newest approved projects.
    final newest = [...catalog]
      ..sort(
        (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
          a.createdAt ?? DateTime(2000),
        ),
      );
    return MatchOutcome(
      status: MatchStatus.noMatch,
      query: q,
      fallback: newest.take(3).map((p) => MatchHit(p, 0, const [])).toList(),
    );
  }

  // ───────────── parsing ─────────────

  static MatchQuery parse(String raw) {
    final t = _norm(raw);
    final tokens = _tokens(t);

    final concepts = <String>{};
    final used = <String>{};
    for (final tok in tokens) {
      _conceptTerms.forEach((id, terms) {
        for (final term in terms) {
          if (_match(tok, term)) {
            concepts.add(id);
            used.add(tok);
            break;
          }
        }
      });
    }

    final techs = _detectTechs(t);
    final keywords = tokens
        .where(
          (w) =>
              w.length >= 3 &&
              !_stop.contains(w) &&
              !used.contains(w) &&
              !_techWords.contains(w) &&
              !RegExp(r'^\d+$').hasMatch(w),
        )
        .toSet();

    final b = _parseBudget(t);
    return MatchQuery(
      concepts: concepts,
      keywords: keywords,
      techs: techs,
      minPrice: b.min,
      maxPrice: b.max,
    );
  }

  /// "under 5000" or "flutter only" after a search refines it
  /// instead of starting a new one.
  static MatchQuery _merge(MatchQuery? prev, MatchQuery now) {
    if (prev == null || !prev.hasTopic) return now;
    final isFollowUp =
        now.concepts.isEmpty &&
        now.keywords.isEmpty &&
        (now.techs.isNotEmpty || now.hasPrice);
    if (!isFollowUp) return now;
    return MatchQuery(
      concepts: prev.concepts,
      keywords: prev.keywords,
      techs: now.techs.isNotEmpty ? now.techs : prev.techs,
      minPrice: now.minPrice ?? prev.minPrice,
      maxPrice: now.maxPrice ?? prev.maxPrice,
    );
  }

  static _Budget _parseBudget(String raw) {
    final t = raw.replaceAllMapped(RegExp(r'(?<=\d),(?=\d{3})'), (_) => '');

    // Range: "3000-8000", "between 3000 and 8k", "من 3000 الي 8000"
    final range = RegExp(
      r'(\d+(?:\.\d+)?)\s*(k|الف|الاف)?\s*(?:-|to|and|الي|حتي|و)\s*(\d+(?:\.\d+)?)\s*(k|الف|الاف)?',
    );
    final r = range.firstMatch(t);
    if (r != null) {
      final unit = r.group(2) ?? r.group(4);
      final mult = unit != null ? 1000 : 1;
      final a = double.parse(r.group(1)!) * mult;
      final b = double.parse(r.group(3)!) * mult;
      if (a >= 100 && b > a) return _Budget(a, b);
    }

    num? min;
    num? max;
    final single = RegExp(r'(\d+(?:\.\d+)?)\s*(k|الف|الاف|thousand)?');
    for (final m in single.allMatches(t)) {
      var v = double.parse(m.group(1)!);
      final hasUnit = m.group(2) != null;
      if (hasUnit) v *= 1000;
      if (v < 500) continue;

      final before = t.substring(math.max(0, m.start - 22), m.start);
      final after = t.substring(m.end, math.min(t.length, m.end + 8));
      final isMin = _minCue.hasMatch(before);
      final isMax = _maxCue.hasMatch(before);
      final hasCur = RegExp(r'egp|جنيه|pound|\ble\b').hasMatch(after);

      // looks like a year, not a price
      if (!hasUnit && !isMin && !isMax && !hasCur && v >= 1990 && v <= 2100) {
        continue;
      }
      if (isMin) {
        min = v;
      } else {
        max = v; // a bare amount is treated as a budget ceiling
      }
    }
    return _Budget(min, max);
  }

  // ───────────── scoring ─────────────

  static List<MatchHit> _search(MatchQuery q, List<MatchProject> catalog) {
    final hits = <MatchHit>[];
    for (final p in catalog) {
      final h = _score(p, q);
      if (h != null) hits.add(h);
    }
    hits.sort((a, b) {
      final c = b.relevance.compareTo(a.relevance);
      if (c != 0) return c;
      return (b.project.createdAt ?? DateTime(2000)).compareTo(
        a.project.createdAt ?? DateTime(2000),
      );
    });
    final inBudget = hits.where((h) => !h.overBudget).toList();
    return inBudget.length >= 2 ? inBudget : hits;
  }

  static MatchHit? _score(MatchProject p, MatchQuery q) {
    final titleTok = _tokens(_norm('${p.title} ${p.category}'));
    final bodyTok = _tokens(
      _norm('${p.description} ${p.techStack.join(' ')} ${p.licenseType}'),
    );
    final titleC = _conceptsOf(titleTok);
    final bodyC = _conceptsOf(bodyTok);
    final techs = _detectTechs(
      _norm('${p.techStack.join(' ')} ${p.title} ${p.description}'),
    );

    double score = 0;
    double max = 0;
    bool topical = false;
    final reasons = <String>[];

    for (final c in q.concepts) {
      final w = _weight(c);
      max += w;
      if (titleC.contains(c)) {
        score += w;
        topical = true;
        reasons.add(_conceptLabels[c] ?? c);
      } else if (bodyC.contains(c)) {
        score += w * 0.7;
        topical = true;
        reasons.add(_conceptLabels[c] ?? c);
      }
    }
    for (final kw in q.keywords) {
      max += 1;
      if (_matchAny(kw, titleTok)) {
        score += 1;
        topical = true;
      } else if (_matchAny(kw, bodyTok)) {
        score += 0.6;
        topical = true;
      }
    }
    for (final t in q.techs) {
      max += 2;
      if (techs.contains(t)) {
        score += 2;
        topical = true;
        reasons.add(_techLabels[t] ?? t);
      }
    }
    if (q.hasTopic && !topical) return null;

    var overBudget = false;
    var mult = 1.0;
    if (q.maxPrice != null) {
      if (p.price <= q.maxPrice!) {
        reasons.add('Within budget');
        max += 1.5;
        score += 1.5;
      } else {
        overBudget = true;
        mult *= p.price <= q.maxPrice! * 1.15 ? 0.8 : 0.5;
      }
    }
    final belowMin = q.minPrice != null && p.price < q.minPrice!;
    if (belowMin) mult *= 0.6;

    double rel;
    if (!q.hasTopic) {
      // budget-only query ("under 5000")
      if (overBudget || belowMin) return null;
      rel = 0.6;
    } else {
      rel = (max == 0 ? 0 : score / max).clamp(0.0, 1.0) * mult;
    }
    if (rel < 0.2) return null;
    return MatchHit(p, rel, reasons, overBudget: overBudget);
  }

  static List<QuickReply> _followUps(List<MatchHit> hits, MatchQuery q) {
    final out = <QuickReply>[];

    if (q.maxPrice == null && hits.length >= 2) {
      final prices = hits.map((h) => h.project.price.toDouble()).toList()
        ..sort();
      final cap = ((prices[prices.length - 2] / 100).ceil() * 100).toInt();
      out.add(QuickReply('Under ${_fmt(cap)} EGP', 'under $cap'));
    }

    final count = <String, int>{};
    for (final h in hits) {
      final p = h.project;
      for (final t in _detectTechs(_norm(p.techStack.join(' ')))) {
        if (!q.techs.contains(t)) count[t] = (count[t] ?? 0) + 1;
      }
    }
    if (count.isNotEmpty) {
      final best = count.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final label = _techLabels[best.key] ?? best.key;
      out.add(QuickReply('Only $label', label));
    }
    if (q.techs.isNotEmpty || q.maxPrice != null) {
      out.add(const QuickReply('Show everything', 'show all'));
    }
    return out.take(3).toList();
  }

  static String _fmt(num n) => n.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  // ───────────── text helpers ─────────────

  static String _norm(String s) {
    var t = s.toLowerCase();
    const ar = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < 10; i++) {
      t = t.replaceAll(ar[i], '$i');
    }
    return t
        .replaceAll(RegExp('[\u064B-\u065F\u0670\u0640]'), '')
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  static List<String> _tokens(String normalized) => RegExp(
    r'[a-z0-9\u0621-\u064A]+',
  ).allMatches(normalized).map((m) => m.group(0)!).toList();

  static final _arabic = RegExp(r'[\u0600-\u06FF]');

  static bool _match(String tok, String term) {
    if (tok == term) return true;
    if (_arabic.hasMatch(term)) return _arMatch(tok, term);
    return term.length >= 4 &&
        tok.startsWith(term) &&
        tok.length <= term.length + 3; // plurals / -ing
  }

  static bool _arMatch(String token, String term) {
    final forms = <String>{token};
    for (final p in const ['وال', 'بال', 'لل', 'ال', 'و', 'ب', 'ل']) {
      if (token.startsWith(p) && token.length > p.length + 1) {
        forms.add(token.substring(p.length));
        break;
      }
    }
    for (final f in forms) {
      if (f == term) return true;
      for (final s in const ['ات', 'ه', 'ين', 'ي', 'ون']) {
        if (f == term + s) return true;
      }
    }
    return false;
  }

  static bool _matchAny(String kw, List<String> tokens) =>
      tokens.any((t) => _match(t, kw) || _match(kw, t));

  static Set<String> _conceptsOf(List<String> tokens) {
    final out = <String>{};
    _conceptTerms.forEach((id, terms) {
      for (final tok in tokens) {
        if (terms.any((term) => _match(tok, term))) {
          out.add(id);
          break;
        }
      }
    });
    return out;
  }

  static Set<String> _detectTechs(String normalized) {
    final out = <String>{};
    _techAliases.forEach((id, aliases) {
      for (final a in aliases) {
        final re = RegExp('(?<![a-z0-9])${RegExp.escape(a)}(?![a-z0-9])');
        if (re.hasMatch(normalized)) {
          out.add(id);
          break;
        }
      }
    });
    return out;
  }

  static double _weight(String c) => (c == 'mobile' || c == 'web') ? 1 : 3;

  static final _techWords = _techAliases.values
      .expand((l) => l)
      .expand((a) => a.split(RegExp(r'[^a-z0-9\u0621-\u064A]+')))
      .where((w) => w.isNotEmpty)
      .toSet();

  static final _minCue = RegExp(
    r'(over|above|more than|at least|minimum|\bmin\b|اكتر|اكثر|فوق|علي الاقل|ابتداء)',
  );
  static final _maxCue = RegExp(
    r'(under|below|less|max|maximum|within|budget|up to|upto|cheap|اقل|تحت|لحد|اقصي|ميزانيت|ميزانيه|في حدود|حتي)',
  );

  // ───────────── dictionaries (edit freely) ─────────────
  // Arabic terms must be written in normalized form:
  // أإآ→ا   ى→ي   ة→ه   (no tashkeel)

  static const _conceptLabels = <String, String>{
    'health': 'Healthcare',
    'booking': 'Booking',
    'ecommerce': 'E-commerce',
    'payment': 'Payments',
    'chatbot': 'Chatbot',
    'ai': 'AI',
    'education': 'Education',
    'delivery': 'Delivery',
    'food': 'Food & dining',
    'realestate': 'Real estate',
    'finance': 'Finance',
    'hr': 'HR & hiring',
    'fitness': 'Fitness',
    'crm': 'CRM',
    'game': 'Games',
    'iot': 'IoT',
    'mobile': 'Mobile',
    'web': 'Web',
  };

  static const _conceptTerms = <String, List<String>>{
    'health': [
      'clinic',
      'hospital',
      'doctor',
      'medical',
      'health',
      'healthcare',
      'patient',
      'pharmacy',
      'dental',
      'عياده',
      'مستشفي',
      'دكتور',
      'طبي',
      'صحه',
      'مريض',
      'صيدليه',
    ],
    'booking': [
      'booking',
      'book',
      'reservation',
      'reserve',
      'appointment',
      'schedule',
      'calendar',
      'slot',
      'حجز',
      'مواعيد',
      'ميعاد',
      'موعد',
    ],
    'ecommerce': [
      'ecommerce',
      'shop',
      'shopping',
      'store',
      'cart',
      'checkout',
      'retail',
      'marketplace',
      'متجر',
      'تسوق',
      'بيع',
      'منتجات',
    ],
    'payment': [
      'payment',
      'pay',
      'wallet',
      'fawry',
      'stripe',
      'invoice',
      'billing',
      'دفع',
      'فواتير',
      'محفظه',
      'فاتوره',
    ],
    'chatbot': [
      'chatbot',
      'chat',
      'bot',
      'assistant',
      'llm',
      'gpt',
      'nlp',
      'support',
      'شات',
      'بوت',
      'محادثه',
      'دعم',
    ],
    'ai': ['ai', 'ml', 'vision', 'prediction', 'recommender', 'ذكاء', 'ذكي'],
    'education': [
      'education',
      'school',
      'student',
      'course',
      'elearning',
      'lms',
      'university',
      'teacher',
      'quiz',
      'تعليم',
      'مدرسه',
      'طالب',
      'كورس',
      'جامعه',
      'مدرس',
    ],
    'delivery': [
      'delivery',
      'logistics',
      'tracking',
      'courier',
      'driver',
      'ride',
      'توصيل',
      'شحن',
      'سواق',
      'تتبع',
    ],
    'food': [
      'restaurant',
      'food',
      'menu',
      'cafe',
      'kitchen',
      'مطعم',
      'اكل',
      'منيو',
      'كافيه',
    ],
    'realestate': [
      'realestate',
      'property',
      'estate',
      'rent',
      'apartment',
      'عقار',
      'شقه',
      'ايجار',
    ],
    'finance': [
      'finance',
      'fintech',
      'bank',
      'loan',
      'accounting',
      'expense',
      'تمويل',
      'بنك',
      'حسابات',
      'محاسبه',
    ],
    'hr': [
      'hr',
      'recruitment',
      'hiring',
      'job',
      'employee',
      'payroll',
      'توظيف',
      'وظائف',
      'موظفين',
      'رواتب',
    ],
    'fitness': ['gym', 'fitness', 'workout', 'sport', 'جيم', 'رياضه', 'تمرين'],
    'crm': [
      'crm',
      'customer',
      'sales',
      'leads',
      'erp',
      'inventory',
      'مبيعات',
      'عملاء',
      'مخزون',
    ],
    'game': ['game', 'gaming', 'لعبه', 'العاب'],
    'iot': ['iot', 'sensor', 'arduino', 'hardware'],
    'mobile': ['mobile', 'android', 'ios', 'app', 'موبايل', 'تطبيق', 'اندرويد'],
    'web': ['website', 'web', 'موقع', 'ويب'],
  };

  static const _techLabels = <String, String>{
    'flutter': 'Flutter',
    'react': 'React',
    'nextjs': 'Next.js',
    'node': 'Node.js',
    'firebase': 'Firebase',
    'supabase': 'Supabase',
    'python': 'Python',
    'django': 'Django',
    'laravel': 'Laravel',
    'php': 'PHP',
    'kotlin': 'Kotlin',
    'swift': 'Swift',
    'java': 'Java',
    'dotnet': '.NET',
    'unity': 'Unity',
    'vue': 'Vue',
    'angular': 'Angular',
    'mongodb': 'MongoDB',
  };

  static const _techAliases = <String, List<String>>{
    'flutter': ['flutter', 'فلاتر'],
    'react': ['react', 'reactjs', 'react.js', 'react native', 'رياكت'],
    'nextjs': ['next.js', 'nextjs', 'next js'],
    'node': ['node.js', 'nodejs', 'node js', 'node'],
    'firebase': ['firebase', 'فايربيز'],
    'supabase': ['supabase'],
    'python': ['python', 'بايثون'],
    'django': ['django'],
    'laravel': ['laravel'],
    'php': ['php'],
    'kotlin': ['kotlin'],
    'swift': ['swift'],
    'java': ['java', 'جافا'],
    'dotnet': ['.net', 'dotnet', 'asp.net'],
    'unity': ['unity'],
    'vue': ['vue', 'vue.js'],
    'angular': ['angular'],
    'mongodb': ['mongodb', 'mongo'],
  };

  static const _greetings = <String>{
    'hi',
    'hello',
    'hey',
    'hola',
    'salam',
    'thanks',
    'thank',
    'you',
    'سلام',
    'مرحبا',
    'اهلا',
    'ازيك',
    'هاي',
    'شكرا',
    'هلا',
    'صباح',
    'الخير',
    'مساء',
  };

  static const _stop = <String>{
    'the',
    'for',
    'with',
    'and',
    'our',
    'want',
    'need',
    'looking',
    'find',
    'that',
    'can',
    'have',
    'please',
    'project',
    'projects',
    'system',
    'something',
    'anything',
    'good',
    'best',
    'nice',
    'some',
    'any',
    'like',
    'would',
    'should',
    'could',
    'under',
    'below',
    'less',
    'than',
    'max',
    'maximum',
    'within',
    'budget',
    'least',
    'above',
    'over',
    'more',
    'between',
    'price',
    'cost',
    'cheap',
    'egp',
    'pound',
    'pounds',
    'what',
    'how',
    'get',
    'make',
    'build',
    'use',
    'using',
    'from',
    'about',
    'show',
    'give',
    'list',
    'all',
    'only',
    'one',
    'who',
    'تحت',
    'عاوز',
    'عايز',
    'محتاج',
    'ابحث',
    'لو',
    'سمحت',
    'ممكن',
    'علي',
    'الي',
    'عن',
    'مع',
    'او',
    'ده',
    'دي',
    'هذا',
    'اريد',
    'ابغي',
    'اقل',
    'فوق',
    'اكتر',
    'جنيه',
    'ميزانيتي',
    'ميزانيه',
    'سعر',
    'مشروع',
    'مشاريع',
    'نظام',
    'فكره',
    'حاجه',
    'انا',
    'عندي',
    'لدي',
    'يكون',
    'تكون',
    'بحيث',
    'كل',
    'بس',
  };
}
