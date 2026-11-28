import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// creator: total = projects, highlight = approved projects, money = earned
/// company: total = orders,   highlight = completed orders,  money = spent
class ProfileStats {
  const ProfileStats({this.total = 0, this.highlight = 0, this.money = 0});
  final int total;
  final int highlight;
  final num money;
}

class ProfileService {
  ProfileService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get uid => _auth.currentUser?.uid;
  bool get emailVerified => _auth.currentUser?.emailVerified ?? false;

  Stream<Map<String, dynamic>?> watch() {
    final id = uid;
    if (id == null) return Stream.value(null);
    return _db.collection('users').doc(id).snapshots().map((d) => d.data());
  }

  /// The owner can edit his own document (role and uid cannot change: rules).
  Future<void> update(Map<String, dynamic> changes) async {
    final id = uid;
    if (id == null) throw FirebaseAuthException(code: 'no-current-user');
    await _db.collection('users').doc(id).update({
      ...changes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ProfileStats> stats(String role) async {
    final id = uid;
    if (id == null) return const ProfileStats();

    num sum(QuerySnapshot<Map<String, dynamic>> s, String field) =>
        s.docs.fold<num>(0, (t, d) {
          final v = d.data()[field];
          return t + (v is num ? v : 0);
        });

    if (role == 'creator') {
      final projects = await _db
          .collection('projects')
          .where('creatorId', isEqualTo: id)
          .get();
      final orders = await _db
          .collection('orders')
          .where('creatorId', isEqualTo: id)
          .get();
      return ProfileStats(
        total: projects.size,
        highlight:
            projects.docs.where((d) => d.data()['status'] == 'approved').length,
        money: sum(orders, 'creatorAmount'),
      );
    }

    final orders = await _db
        .collection('orders')
        .where('companyId', isEqualTo: id)
        .get();
    return ProfileStats(
      total: orders.size,
      highlight:
          orders.docs.where((d) => d.data()['status'] == 'completed').length,
      money: sum(orders, 'price'),
    );
  }
}