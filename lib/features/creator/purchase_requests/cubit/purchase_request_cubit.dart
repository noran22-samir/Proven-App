// المسار: lib/features/creator/purchase_requests/cubit/purchase_request_cubit.dart   (بدّل الملف كله)
//
// بيقرا طلبات الشراء الحقيقية (orders) بدل الداتا الوهمية، وبيحوّلها لنفس شكل الكارت القديم.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, Timestamp;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proven/features/projects/creator_orders_repository.dart';
import 'package:proven/features/projects/projects_repository.dart';
import 'purchase_request_state.dart';

class PurchaseRequestCubit extends Cubit<PurchaseRequestState> {
  PurchaseRequestCubit({CreatorOrdersRepository? repo})
      : _repo = repo ?? CreatorOrdersRepository(),
        super(PurchaseRequestLoading()) {
    _sub = _repo.creatorOrders().listen(
      (rows) {
        contracts = rows.map(_toCard).toList();
        _stats(rows);
        emit(PurchaseRequestSuccess());
      },
      onError: (_) =>
          emit(PurchaseRequestError('Could not load your purchase requests.')),
    );
  }

  final CreatorOrdersRepository _repo;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  static const filters = ['All', 'Paid', 'Delivered', 'Completed'];
  String selectedFilter = 'All';

  List<Map<String, dynamic>> contracts = [];

  String totalEarnings = '0'; // اللي اتحرر فعلاً (completed)
  String inEscrow = '0'; // لسه محجوز (paid + delivered)
  String totalRequests = '0';

  List<Map<String, dynamic>> get visible => selectedFilter == 'All'
      ? contracts
      : contracts.where((c) => c['status'] == selectedFilter).toList();

  void changeFilter(String f) {
    selectedFilter = f;
    emit(PurchaseRequestSuccess());
  }

  /// null = نجح، غير كده رسالة خطأ
  Future<String?> deliver(String orderId, String link) async {
    final uri = Uri.tryParse(link.trim());
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return 'Enter a valid link starting with https://';
    }
    try {
      await _repo.deliver(orderId, link.trim());
      return null;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          return 'You can not deliver this order (maybe it was already delivered).';
        case 'unavailable':
          return 'No connection. Check your internet.';
        default:
          return 'Could not deliver. Try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  void _stats(List<Map<String, dynamic>> rows) {
    num earned = 0, escrow = 0;
    for (final o in rows) {
      final amount = o['creatorAmount'] is num ? o['creatorAmount'] as num : 0;
      if (o['status'] == 'completed') {
        earned += amount;
      } else {
        escrow += amount;
      }
    }
    totalEarnings = _fmt(earned);
    inEscrow = _fmt(escrow);
    totalRequests = '${rows.length}';
  }

  String _fmt(num n) => n
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  // ───────────── order → شكل الكارت ─────────────

  Map<String, dynamic> _toCard(Map<String, dynamic> o) {
    final raw = '${o['status'] ?? 'paid'}';
    final name = '${o['companyName'] ?? ''}'.trim();
    final price = o['price'];
    final fee = o['platformFee'];
    final net = o['creatorAmount'];
    return {
      'id': o['id'],
      'raw': raw,
      'status': _label(raw),
      'initials': _initials(name),
      'companyName': name.isEmpty ? 'Company' : name,
      'companySubtitle': '${o['companyIndustry'] ?? ''}'.isEmpty
          ? 'Company'
          : '${o['companyIndustry']}',
      'date': _date(o['createdAt']),
      'projectTitle': '${o['projectTitle'] ?? ''}'.isEmpty
          ? 'Project'
          : '${o['projectTitle']}',
      'purchasePrice': price is num ? ProjectsRepository.egp(price) : '—',
      'netReceive': net is num ? ProjectsRepository.egp(net) : '—',
      'feeValue': fee is num ? fee : null,
      'deliveryLink': '${o['deliveryLink'] ?? ''}',
    };
  }

  String _label(String s) {
    switch (s) {
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      default:
        return 'Paid';
    }
  }

  String _initials(String name) {
    final p = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    if (p.length == 1) {
      return p.first.substring(0, p.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (p[0][0] + p[1][0]).toUpperCase();
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