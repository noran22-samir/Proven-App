// المسار: lib/features/projects/projects_repository.dart   (بدّل الملف القديم)
//
// متظبط على الـ rules بتاعتك:
//  - creatorId (مش ownerId)
//  - images لازم list فيها عنصر واحد على الأقل
//  - termsVersion == 'v1'
//  - price رقم بين 100 و 100000
//  - الكريتور يقدر يخلي status = pending / archived بس
//  - الأدمن يقدر يخلي status = approved / rejected / unpublished بس

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectsRepository {
  ProjectsRepository({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const termsVersion = 'v1';
  static const minPrice = 100;
  static const maxPrice = 100000;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('projects');

  /// "8,500 EGP"
  static String egp(num n) =>
      '${n.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')} EGP';

  // ───────────── Creator ─────────────

  /// يضيف مشروع بحالة pending.
  /// images: مؤقتًا placeholder لحد ما نربط Firebase Storage (الـ rules بتطلب صورة واحدة على الأقل).
  Future<String> submit({
    required String title,
    required String description,
    required String category,
    required num price,
    List<String> techStack = const [],
    String licenseType = 'turnkey',
    List<String> images = const ['placeholder'], // TODO: روابط Storage
    String demoLink = '',
    String githubLink = '',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'no-current-user');

    final u = (await _db.collection('users').doc(user.uid).get()).data() ?? {};
    var ownerName = '${u['name'] ?? ''}'.trim();

    if (ownerName.isEmpty) {
      ownerName = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
    }

    if (ownerName.isEmpty) {
      ownerName = user.displayName ?? user.email ?? 'Creator';
    }

    final ref = await _col.add({
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'techStack': techStack,
      'licenseType': licenseType,
      'images': images,
      'demoLink': demoLink,
      'githubLink': githubLink,
      'status': 'pending',
      'creatorId': user.uid,
      'ownerName': ownerName, // الـ Matchmaker بيقراه
      'termsVersion': termsVersion,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// مشاريعي (الترتيب على الموبايل علشان منحتاجش index)
  Stream<List<Map<String, dynamic>>> myProjects() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.error(StateError('User is not logged in.'));
    }
    return _col.where('creatorId', isEqualTo: uid).snapshots().map(_sorted);
  }

  /// تعديل وإعادة إرسال للمراجعة
  Future<void> resubmit(String id, Map<String, dynamic> changes) {
    return _col.doc(id).update({
      ...changes,
      'status': 'pending',
      'rejectionReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> archive(String id) => _col.doc(id).update({
    'status': 'archived',
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> delete(String id) => _col.doc(id).delete();

  // ───────────── Admin ─────────────

  Stream<List<Map<String, dynamic>>> pendingProjects() =>
      _col.where('status', isEqualTo: 'pending').snapshots().map(_sorted);

  /// status: approved | rejected | unpublished
  Future<void> review(String id, String status, {String? reason}) {
    if (!const ['approved', 'rejected', 'unpublished'].contains(status)) {
      throw ArgumentError('Invalid project status.');
    }
    return _col.doc(id).update({
      'status': status,
      'rejectionReason': status == 'approved' ? FieldValue.delete() : (reason ?? ''),
      'reviewedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ───────────── Company / Market ─────────────

  Stream<List<Map<String, dynamic>>> approvedProjects() =>
      _col.where('status', isEqualTo: 'approved').snapshots().map(_sorted);

  Future<Map<String, dynamic>?> getById(String id) async {
    final d = await _col.doc(id).get();
    final data = d.data();
    return data == null ? null : {...data, 'id': d.id};
  }

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
