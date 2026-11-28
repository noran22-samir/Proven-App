// المسار: lib/features/creator/my_project/cubit/my_project_cubit.dart   (بدّل الملف كله)
//
// بيقرا مشاريع الكريتور الحقيقية (live). أضفت للكارت: image, description, techStack, priceValue
// علشان شاشة التعديل تقدر تعدّل كل الحاجات المهمة.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, Timestamp;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proven/features/projects/project_cover.dart';
import 'package:proven/features/projects/projects_repository.dart';
import 'my_project_state.dart';

class MyProjectCubit extends Cubit<MyProjectState> {
  MyProjectCubit({ProjectsRepository? repo})
      : _repo = repo ?? ProjectsRepository(),
        super(MyProjectLoading()) {
    _sub = _repo.myProjects().listen(
      (docs) {
        projects = docs.map(_toCard).toList();
        emit(MyProjectSuccess());
      },
      onError: (_) => emit(MyProjectError('Could not load your projects.')),
    );
  }

  final ProjectsRepository _repo;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  int selectedIndex = 0;
  List<Map<String, dynamic>> projects = [];

  void changeFilter(int index) {
    selectedIndex = index;
    emit(MyProjectSuccess());
  }

  /// يرجّع null لو نجح، أو رسالة خطأ.
  /// التعديل بيرجّع المشروع "Pending" لحد ما الأدمن يراجعه (حتى لو كان معتمد).
  Future<String?> updateProject({
    required String projectId,
    required String title,
    required String description,
    required String category,
    required String priceText,
    required List<String> techStack,
  }) async {
    final price = num.tryParse(priceText.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (title.trim().isEmpty) return 'Title is required.';
    if (description.trim().isEmpty) return 'Description is required.';
    if (category.trim().isEmpty) return 'Category is required.';
    if (price == null ||
        price < ProjectsRepository.minPrice ||
        price > ProjectsRepository.maxPrice) {
      return 'Price must be between 100 and 100,000 EGP.';
    }
    return _run(() => _repo.resubmit(projectId, {
          'title': title.trim(),
          'description': description.trim(),
          'category': category.trim(),
          'price': price,
          'techStack': techStack,
        }));
  }

  Future<String?> deleteProject(String projectId) =>
      _run(() => _repo.delete(projectId));

  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          return 'You are not allowed to do this.';
        case 'unavailable':
          return 'No connection. Check your internet.';
        default:
          return 'Could not complete the action. Try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ───────────── Firestore doc → الشكل اللي الشاشة فاهماه ─────────────

  Map<String, dynamic> _toCard(Map<String, dynamic> d) {
    final status = '${d['status'] ?? 'pending'}';
    final price = d['price'];
    final tech = d['techStack'];
    final reason = '${d['rejectionReason'] ?? ''}'.trim();
    return {
      'id': d['id'],
      'title': '${d['title'] ?? ''}',
      'description': '${d['description'] ?? ''}',
      'category': '${d['category'] ?? ''}',
      'price': price is num ? ProjectsRepository.egp(price) : '—',
      'priceValue': price is num ? price : null,
      'techStack': tech is List ? tech.map((e) => '$e').toList() : <String>[],
      'image': ProjectCover.firstImage(d['images']),
      'status': _label(status),
      'subText': _date(d['createdAt']),
      if (status == 'rejected')
        'reason': reason.isEmpty ? 'No reason was given.' : reason,
    };
  }

  String _label(String s) {
    switch (s) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'archived':
        return 'Archived';
      case 'unpublished':
        return 'Unpublished';
      default:
        return 'Pending';
    }
  }

  String _date(dynamic ts) {
    if (ts is! Timestamp) return 'Just now';
    final d = ts.toDate();
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}