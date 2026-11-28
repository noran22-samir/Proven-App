// lib/features/ai_matchmaker/ai_matchmaker_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'matchmaker_engine.dart';
import 'matchmaker_service.dart';

// ───────────────────────── Tokens ─────────────────────────
class _C {
  static const bg = Color(0xFF050E1A);
  static const panel = Color(0xFF0A1A2C);
  static const card = Color(0xFF0F2238);
  static const line = Color(0xFF1D3A5A);
  static const text = Color(0xFFE6EEF7);
  static const muted = Color(0xFF7F96B0);
  static const accent = Color(0xFF38A6F0);
  static const userBubble = Color(0xFF0C3B63);
  static const ai = Color(0xFF8F7CF5);
  static const good = Color(0xFF34D399);
  static const gold = Color(0xFFF5B83D);
  static const warn = Color(0xFFF59E0B);
  static const danger = Color(0xFFF87171);
}

TextStyle _t(double size,
        {FontWeight w = FontWeight.w400, Color c = _C.text, double? h}) =>
    GoogleFonts.ibmPlexSans(fontSize: size, fontWeight: w, color: c, height: h);

TextStyle _mono(double size, {Color c = _C.muted}) =>
    GoogleFonts.ibmPlexMono(fontSize: size, color: c);

String _time(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
}

String _price(num n) => n
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

String _license(String raw) {
  switch (raw) {
    case 'turnkey':
      return 'Turnkey license';
    case 'source':
      return 'Includes source code';
    case 'enterprise':
      return 'Enterprise ready';
    default:
      return raw;
  }
}

IconData _iconFor(MatchProject p) {
  final c = '${p.category} ${p.title}'.toLowerCase();
  bool has(List<String> w) => w.any(c.contains);
  if (has(['health', 'clinic', 'medical', 'doctor'])) {
    return Icons.medical_services_outlined;
  }
  if (has(['shop', 'commerce', 'store', 'cart'])) {
    return Icons.shopping_cart_outlined;
  }
  if (has(['chat', 'bot', 'ai'])) return Icons.smart_toy_outlined;
  if (has(['educ', 'school', 'course', 'learn'])) return Icons.school_outlined;
  if (has(['financ', 'bank', 'pay', 'wallet'])) {
    return Icons.account_balance_wallet_outlined;
  }
  if (has(['food', 'restaurant', 'cafe'])) return Icons.restaurant_outlined;
  if (has(['book', 'appoint', 'schedul'])) return Icons.calendar_month_outlined;
  if (has(['deliver', 'logistic', 'ride'])) return Icons.local_shipping_outlined;
  return Icons.widgets_outlined;
}

// ───────────────────────── Message model ─────────────────────────
enum _Role { ai, user }

class _Msg {
  _Msg._({
    required this.role,
    this.text,
    this.headline,
    this.hits = const [],
    this.chips = const [],
    this.retryText,
    this.isError = false,
  }) : time = DateTime.now();

  factory _Msg.user(String text) => _Msg._(role: _Role.user, text: text);

  factory _Msg.ai({
    String? text,
    String? headline,
    List<MatchHit> hits = const [],
    List<QuickReply> chips = const [],
  }) =>
      _Msg._(
          role: _Role.ai,
          text: text,
          headline: headline,
          hits: hits,
          chips: chips);

  factory _Msg.error(String text, String retryText) => _Msg._(
      role: _Role.ai, text: text, retryText: retryText, isError: true);

  final _Role role;
  final String? text;
  final String? headline;
  final List<MatchHit> hits;
  final List<QuickReply> chips;
  final String? retryText;
  final bool isError;
  final DateTime time;
}

const _starters = <QuickReply>[
  QuickReply('I need a booking system for a clinic',
      'I need a booking system for a clinic'),
  QuickReply('E-commerce mobile app with payment',
      'E-commerce mobile app with payment'),
  QuickReply('AI customer support chatbot', 'AI customer support chatbot'),
];

// ───────────────────────── Screen ─────────────────────────
class AiMatchmakerScreen extends StatefulWidget {
  const AiMatchmakerScreen({
    super.key,
    required this.service,
    required this.onOpenProject,
    this.onBack,
  });

  final MatchmakerService service;
  final ValueChanged<String> onOpenProject; // receives projectId
  final VoidCallback? onBack;

  @override
  State<AiMatchmakerScreen> createState() => _AiMatchmakerScreenState();
}

class _AiMatchmakerScreenState extends State<AiMatchmakerScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  MatchQuery? _query;
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    widget.service.warmUp();
    _greet();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _greet() {
    _msgs
      ..clear()
      ..add(_Msg.ai(
        text:
            "Hi! Tell me what your company needs and I'll find the best verified projects for your stack and budget.",
        chips: _starters,
      ));
    _query = null;
  }

  void _reset() {
    widget.service.invalidate();
    widget.service.warmUp();
    setState(_greet);
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _thinking) return;
    _controller.clear();
    setState(() {
      _msgs.add(_Msg.user(text));
      _thinking = true;
    });
    _scrollDown();

    final started = DateTime.now();
    try {
      final out = await widget.service.ask(text, previous: _query);
      // tiny pause so the typing indicator is readable
      final spent = DateTime.now().difference(started).inMilliseconds;
      if (spent < 650) {
        await Future.delayed(Duration(milliseconds: 650 - spent));
      }
      if (!mounted) return;
      if (out.status == MatchStatus.results) _query = out.query;
      setState(() {
        _msgs.add(_fromOutcome(out));
        _thinking = false;
      });
    } on MatchmakerException catch (e) {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg.error(e.message, text));
        _thinking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _msgs.add(_Msg.error('Something went wrong. Please try again.', text));
        _thinking = false;
      });
    }
    _scrollDown();
  }

  void _retry(String text) {
    setState(() {
      if (_msgs.isNotEmpty) _msgs.removeLast(); // error bubble
      if (_msgs.isNotEmpty) _msgs.removeLast(); // the question
    });
    _send(text);
  }

  _Msg _fromOutcome(MatchOutcome o) {
    switch (o.status) {
      case MatchStatus.greeting:
        return _Msg.ai(
          text:
              'Hi! Describe the project you need: what it should do, the industry, and optionally a tech stack or budget.',
          chips: _starters,
        );
      case MatchStatus.needMoreInfo:
        return _Msg.ai(
          text:
              'I need a bit more to go on. What should the project do, and for which industry? You can add a tech stack or a budget too.',
          chips: _starters,
        );
      case MatchStatus.results:
        final n = o.hits.length;
        final more = o.total > n ? ' (top $n of ${o.total})' : '';
        return _Msg.ai(
          headline: n == 1
              ? 'I found 1 project that matches your need$more:'
              : 'I found $n projects that match your need$more:',
          hits: o.hits,
          text:
              'Want to narrow it down? Pick a filter below, or tell me your budget and preferred stack.',
          chips: o.followUps,
        );
      case MatchStatus.noMatch:
        if (o.fallback.isEmpty) {
          return _Msg.ai(
            text:
                'There are no approved projects on the marketplace yet. Check back soon.',
          );
        }
        return _Msg.ai(
          headline: o.relaxed
              ? 'Nothing matches those filters. Here are the closest results without them:'
              : 'No close match yet. Try different words, or browse the newest projects:',
          hits: o.fallback,
          chips: o.relaxed
              ? const [QuickReply('Show everything', 'show all')]
              : _starters,
        );
    }
  }

  void _showInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _C.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How matching works', style: _t(17, w: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              'Describe your need in English or Arabic. Matchmaker compares it with every approved project: industry, features, tech stack and price. '
              'The best matches come first, and each card shows why it matched.\n\n'
              'Matching runs on your device. What you type is not sent to any AI service.',
              style: _t(14, c: _C.muted, h: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _msgs.length - 1;
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
                onBack: widget.onBack, onReset: _reset, onInfo: _showInfo),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _msgs.length + (_thinking ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _msgs.length) return const _TypingRow();
                  final m = _msgs[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: m.role == _Role.user
                        ? _UserRow(msg: m)
                        : _AiRow(
                            msg: m,
                            showChips: i == last && !_thinking,
                            onChip: _send,
                            onOpen: widget.onOpenProject,
                            onRetry: m.retryText == null
                                ? null
                                : () => _retry(m.retryText!),
                          ),
                  );
                },
              ),
            ),
            _Composer(
                controller: _controller, busy: _thinking, onSend: _send),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Header ─────────────────────────
class _Header extends StatelessWidget {
  const _Header(
      {required this.onBack, required this.onReset, required this.onInfo});
  final VoidCallback? onBack;
  final VoidCallback onReset;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: const BoxDecoration(
        color: _C.panel,
        border: Border(bottom: BorderSide(color: _C.line)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: _C.accent),
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 8),
          const _AiAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Matchmaker', style: _t(16, w: FontWeight.w600)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: _C.good, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('Company mode', style: _t(12, c: _C.good)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.refresh, color: _C.accent),
            tooltip: 'Start over',
          ),
          IconButton(
            onPressed: onInfo,
            icon: const Icon(Icons.info_outline, color: _C.accent),
            tooltip: 'How it works',
          ),
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  const _AiAvatar();
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _C.ai.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.ai.withValues(alpha: 0.6)),
        ),
        child: const Icon(Icons.auto_awesome, color: _C.ai, size: 18),
      );
}

// ───────────────────────── Rows ─────────────────────────
class _UserRow extends StatelessWidget {
  const _UserRow({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _C.userBubble,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.accent.withValues(alpha: 0.5)),
          ),
          child: Text(msg.text ?? '', style: _t(15, h: 1.35)),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_time(msg.time), style: _mono(11)),
            const SizedBox(width: 6),
            const Icon(Icons.done_all, size: 14, color: _C.good),
          ],
        ),
      ],
    );
  }
}

class _AiRow extends StatelessWidget {
  const _AiRow({
    required this.msg,
    required this.showChips,
    required this.onChip,
    required this.onOpen,
    required this.onRetry,
  });

  final _Msg msg;
  final bool showChips;
  final ValueChanged<String> onChip;
  final ValueChanged<String> onOpen;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AiAvatar(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.hits.isNotEmpty) ...[
                _ResultsCard(
                    headline: msg.headline ?? '',
                    hits: msg.hits,
                    onOpen: onOpen),
                if (msg.text != null) ...[
                  const SizedBox(height: 8),
                  _Bubble(text: msg.text!),
                ],
              ] else
                _Bubble(text: msg.text ?? '', isError: msg.isError),
              if (msg.isError && onRetry != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.accent,
                      side: const BorderSide(color: _C.line),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text('${_time(msg.time)} · Proven AI', style: _mono(11)),
              if (showChips && msg.chips.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in msg.chips)
                      ActionChip(
                        label: Text(c.label,
                            style: _t(13, c: _C.text),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        onPressed: () => onChip(c.text),
                        backgroundColor: _C.card,
                        side: const BorderSide(color: _C.line),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, this.isError = false});
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isError ? _C.danger : _C.line),
        ),
        child: Text(text, style: _t(15, h: 1.4)),
      );
}

// ───────────────────────── Results ─────────────────────────
class _ResultsCard extends StatelessWidget {
  const _ResultsCard(
      {required this.headline, required this.hits, required this.onOpen});
  final String headline;
  final List<MatchHit> hits;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: _t(15, w: FontWeight.w600, h: 1.35)),
          const SizedBox(height: 12),
          for (var i = 0; i < hits.length; i++) ...[
            _ProjectTile(
              hit: hits[i],
              isBest: i == 0 && hits[i].percent >= 50,
              onTap: () => onOpen(hits[i].project.id),
            ),
            if (i != hits.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile(
      {required this.hit, required this.isBest, required this.onTap});
  final MatchHit hit;
  final bool isBest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = hit.project;
    final license = _license(p.licenseType);
    final tech = p.techStack.take(3).join(' · ');
    final reasons = hit.reasons.take(4).toList();

    return Material(
      color: _C.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isBest ? _C.accent.withValues(alpha: 0.7) : _C.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBest || hit.percent > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      if (isBest)
                        _Pill(
                            icon: Icons.star_outline,
                            label: 'Best match',
                            color: _C.gold),
                      const Spacer(),
                      if (hit.percent > 0)
                        Text('${hit.percent}% match',
                            style: _t(12, w: FontWeight.w600, c: _C.good)),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _C.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.line),
                    ),
                    child: Icon(_iconFor(p), color: _C.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(p.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _t(16, w: FontWeight.w600)),
                            ),
                            const Icon(Icons.chevron_right,
                                color: _C.muted, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [if (p.category.isNotEmpty) p.category, if (tech.isNotEmpty) tech]
                              .join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _t(12.5, c: _C.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (reasons.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final r in reasons)
                      _Pill(
                          label: r,
                          color: r == 'Within budget' ? _C.good : _C.accent),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1, color: _C.line),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(license.isEmpty ? 'License on request' : license,
                        style: _t(12.5, c: _C.muted)),
                  ),
                  if (hit.overBudget) ...[
                    Text('Over budget  ', style: _t(11.5, c: _C.warn)),
                  ],
                  Text(_price(p.price),
                      style: _t(16,
                          w: FontWeight.w700,
                          c: hit.overBudget ? _C.warn : _C.text)),
                  const SizedBox(width: 4),
                  Text('EGP', style: _t(11, c: _C.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
            ],
            Text(label, style: _t(11.5, w: FontWeight.w600, c: color)),
          ],
        ),
      );
}

// ───────────────────────── Typing ─────────────────────────
class _TypingRow extends StatefulWidget {
  const _TypingRow();
  @override
  State<_TypingRow> createState() => _TypingRowState();
}

class _TypingRowState extends State<_TypingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const _AiAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.line),
            ),
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final phase = (_c.value - i * 0.18) % 1.0;
                  final o = 0.3 + 0.7 * math.sin(phase * math.pi);
                  return Container(
                    width: 7,
                    height: 7,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: _C.ai.withValues(alpha: o.clamp(0.3, 1.0)),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Composer ─────────────────────────
class _Composer extends StatelessWidget {
  const _Composer(
      {required this.controller, required this.busy, required this.onSend});
  final TextEditingController controller;
  final bool busy;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: _C.panel,
        border: Border(top: BorderSide(color: _C.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !busy,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              style: _t(15),
              cursorColor: _C.accent,
              decoration: InputDecoration(
                hintText: 'Describe what you need…',
                hintStyle: _t(15, c: _C.muted),
                filled: true,
                fillColor: _C.bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.line),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _C.accent),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            height: 50,
            child: Material(
              color: busy ? _C.line : _C.userBubble,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: busy ? _C.line : _C.accent),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: busy ? null : () => onSend(controller.text),
                child: const Icon(Icons.send_rounded, color: _C.text, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
