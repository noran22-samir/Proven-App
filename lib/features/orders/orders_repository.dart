// PATH: lib/features/orders/orders_repository.dart
// ACTION: NEW file. Create a NEW folder: lib/features/orders/
//
// Everything about the "orders" collection, matching firestore.rules:
//  - company creates an order with status 'paid' (price, creatorId, fee 10%, creator 90%)
//  - creator moves paid -> delivered (deliveryLink)
//  - admin moves delivered -> completed
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderException implements Exception {
  const OrderException(this.code);

  /// project-unavailable | already-purchased | not-signed-in
  final String code;

  @override
  String toString() => code;
}

class OrdersRepository {
  OrdersRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('orders');

  static String _txnId() {
    final r = Random.secure().nextInt(9000) + 1000;
    return 'TXN-${DateTime.now().millisecondsSinceEpoch}-$r';
  }

  // ───────────── Company ─────────────

  /// Mock payment: no real money, it only creates the order.
  /// Returns the new order id.
  Future<String> buy(String projectId) async {
    final user = _auth.currentUser;
    if (user == null) throw const OrderException('not-signed-in');

    final snap = await _db.collection('projects').doc(projectId).get();
    final p = snap.data();
    if (p == null || p['status'] != 'approved' || p['price'] is! num) {
      throw const OrderException('project-unavailable');
    }

    if (await hasPurchased(projectId)) {
      throw const OrderException('already-purchased');
    }

    final price = p['price'] as num;
    final u = (await _db.collection('users').doc(user.uid).get()).data() ?? {};
    var companyName = '${u['companyName'] ?? ''}'.trim();
    if (companyName.isEmpty) companyName = user.email ?? 'Company';

    final ref = await _col.add({
      'projectId': projectId,
      'projectTitle': '${p['title'] ?? ''}',
      'companyId': user.uid,
      'companyName': companyName,
      'creatorId': p['creatorId'],
      'creatorName': '${p['ownerName'] ?? p['creatorName'] ?? ''}',
      'price': price,
      // the rules check these two with the SAME formula
      'platformFee': price * 0.1,
      'creatorAmount': price * 0.9,
      'transactionId': _txnId(),
      'status': 'paid',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<bool> hasPurchased(String projectId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    try {
      final s = await _col
          .where('companyId', isEqualTo: uid)
          .where('projectId', isEqualTo: projectId)
          .limit(1)
          .get();
      return s.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> companyOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.error(StateError('Not logged in.'));
    return _col.where('companyId', isEqualTo: uid).snapshots().map(_sorted);
  }

  // ───────────── Creator ─────────────

  Stream<List<Map<String, dynamic>>> creatorOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.error(StateError('Not logged in.'));
    return _col.where('creatorId', isEqualTo: uid).snapshots().map(_sorted);
  }

  Future<void> deliver(String orderId, String deliveryLink) =>
      _col.doc(orderId).update({
        'status': 'delivered',
        'deliveryLink': deliveryLink,
        'deliveredAt': FieldValue.serverTimestamp(),
      });

  // ───────────── Admin ─────────────

  Stream<List<Map<String, dynamic>>> allOrders() =>
      _col.snapshots().map(_sorted);

  Future<void> complete(String orderId) => _col.doc(orderId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

  List<Map<String, dynamic>> _sorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    list.sort((a, b) {
      final ta = a['createdAt'];
      final tb = b['createdAt'];
      if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
      return 0;
    });
    return list;
  }
}