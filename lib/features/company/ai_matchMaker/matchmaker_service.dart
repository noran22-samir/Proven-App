// lib/features/ai_matchmaker/matchmaker_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'matchmaker_engine.dart';

class MatchmakerException implements Exception {
  MatchmakerException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Loads approved projects once (cached 5 min) and matches locally.
/// One cheap read per session instead of one read per message.
class MatchmakerService {
  MatchmakerService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  List<MatchProject>? _cache;
  DateTime? _loadedAt;
  static const _ttl = Duration(minutes: 5);

  /// Call from initState so the first question is instant.
  Future<void> warmUp() async {
    try {
      await _catalog();
    } catch (_) {}
  }

  /// Forces a fresh read on the next question (used by the reset button).
  void invalidate() => _loadedAt = null;

  Future<MatchOutcome> ask(String text, {MatchQuery? previous}) async {
    final catalog = await _catalog();
    return MatchEngine.run(text, catalog, previous: previous);
  }

  Future<List<MatchProject>> _catalog() async {
    final fresh = _cache != null &&
        _loadedAt != null &&
        DateTime.now().difference(_loadedAt!) < _ttl;
    if (fresh) return _cache!;

    try {
      final snap = await _db
          .collection('projects')
          .where('status', isEqualTo: 'approved')
          .limit(300)
          .get();
      _cache = snap.docs.map((d) => _fromDoc(d.id, d.data())).toList();
      _loadedAt = DateTime.now();
      return _cache!;
    } on FirebaseException catch (e) {
      if (_cache != null) return _cache!; // offline: use the last good copy
      throw MatchmakerException(_message(e.code));
    } catch (_) {
      if (_cache != null) return _cache!;
      throw MatchmakerException('Something went wrong. Please try again.');
    }
  }

  MatchProject _fromDoc(String id, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    final tech = m['techStack'];
    return MatchProject(
      id: id,
      title: '${m['title'] ?? ''}',
      description: '${m['description'] ?? ''}',
      category: '${m['category'] ?? ''}',
      price: m['price'] is num ? m['price'] as num : 0,
      techStack: tech is List ? tech.map((e) => '$e').toList() : const [],
      licenseType: '${m['licenseType'] ?? ''}',
      ownerName: '${m['ownerName'] ?? ''}',
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  String _message(String code) {
    switch (code) {
      case 'unavailable':
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      case 'permission-denied':
        return 'You do not have access to the marketplace right now. Log in again.';
      default:
        return 'Could not load projects. Please try again.';
    }
  }
}
