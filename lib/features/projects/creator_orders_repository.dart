// المسار: lib/features/projects/creator_orders_repository.dart   (ملف جديد، اسم جديد علشان ميتعارضش مع OrdersRepository بتاع الشركة/الأدمن)
//
// جانب الكريتور من الطلبات (orders) متظبط على الـ rules:
//  - الكريتور يقرا الطلبات اللي creatorId بتاعها هو
//  - الكريتور يقدر ينقل الطلب من paid إلى delivered بس، ويغيّر (status, deliveryLink, deliveredAt) بس
//  - الأدمن هو اللي ينقله من delivered إلى completed

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatorOrdersRepository {
  CreatorOrdersRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  // كاش صغير علشان منعيدش قراءة نفس الشركة/المشروع
  final Map<String, Map<String, dynamic>> _companies = {};
  final Map<String, String> _projectTitles = {};

  /// طلبات الكريتور (الأحدث الأول). بيكمّل اسم الشركة وعنوان المشروع لو مش متخزنين في الطلب.
  Stream<List<Map<String, dynamic>>> creatorOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.error(StateError('User is not logged in.'));

    return _db
        .collection('orders')
        .where('creatorId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snap) async {
      final list = <Map<String, dynamic>>[];
      for (final d in snap.docs) {
        final m = <String, dynamic>{...d.data(), 'id': d.id};
        await _fill(m);
        list.add(m);
      }
      list.sort((a, b) {
        final ta = a['createdAt'];
        final tb = b['createdAt'];
        if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
        return 0;
      });
      return list;
    });
  }

  Future<void> _fill(Map<String, dynamic> m) async {
    try {
      if ('${m['companyName'] ?? ''}'.isEmpty) {
        final id = '${m['companyId'] ?? ''}';
        if (id.isNotEmpty) {
          final c = _companies[id] ??=
              (await _db.collection('users').doc(id).get()).data() ?? {};
          m['companyName'] = '${c['companyName'] ?? ''}';
          m['companyIndustry'] = '${c['industry'] ?? ''}';
        }
      }
      if ('${m['projectTitle'] ?? ''}'.isEmpty) {
        final pid = '${m['projectId'] ?? ''}';
        if (pid.isNotEmpty) {
          m['projectTitle'] = _projectTitles[pid] ??=
              '${(await _db.collection('projects').doc(pid).get()).data()?['title'] ?? ''}';
        }
      }
    } catch (_) {
      // لو فشلنا نجيب الاسم، الشاشة هتعرض قيمة افتراضية
    }
  }

  /// الكريتور يسلّم المشروع: paid → delivered
  Future<void> deliver(String orderId, String link) {
    return _db.collection('orders').doc(orderId).update({
      'status': 'delivered',
      'deliveryLink': link,
      'deliveredAt': FieldValue.serverTimestamp(),
    });
  }
}