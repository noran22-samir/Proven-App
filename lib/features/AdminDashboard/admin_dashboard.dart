import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/orders/orders_repository.dart';
import 'package:proven/features/projects/projects_repository.dart';
import 'admin_dashboard_header.dart';
import 'admin_dashboard_stats.dart';
import 'admin_order_card.dart';
import 'admin_project_review_page.dart';
import 'admin_ui.dart';
import 'order_details_sheet.dart';
import 'project_card.dart';

typedef _Map = Map<String, dynamic>;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _projects = ProjectsRepository();
  final _orders = OrdersRepository();
  final List<StreamSubscription<dynamic>> _subs = [];

  List<_Map>? _pending;
  List<_Map>? _published;
  List<_Map>? _allOrders;
  bool _error = false;

  int _tab = 0; // 0 pending, 1 orders, 2 published
  String _orderFilter = 'all';

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  void _cancel() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  void _listen() {
    _cancel();
    void onError(Object _) {
      if (mounted) setState(() => _error = true);
    }

    _subs.addAll([
      _projects.pendingProjects().listen((v) {
        if (mounted) setState(() => _pending = v);
      }, onError: onError),
      _projects.approvedProjects().listen((v) {
        if (mounted) setState(() => _published = v);
      }, onError: onError),
      _orders.allOrders().listen((v) {
        if (mounted) setState(() => _allOrders = v);
      }, onError: onError),
    ]);
  }

  void _retry() {
    setState(() {
      _error = false;
      _pending = null;
      _published = null;
      _allOrders = null;
    });
    _listen();
  }

  bool get _loading =>
      _pending == null || _published == null || _allOrders == null;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openReview(_Map project) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AdminProjectReviewPage(project: project),
      ),
    );
    if (result != null && mounted) _snack(result);
  }

  Future<void> _openOrder(_Map order) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderDetailsSheet(order: order),
    );
    if (done == true && mounted) _snack('Order marked as completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                AdminDashboardHeader(onLogout: widget.onLogout),
                const SizedBox(height: 18),
                if (_error)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: AdminNotice(
                      icon: Icons.cloud_off_rounded,
                      text:
                          'Could not load the dashboard.\nCheck your internet and make sure this is an admin account.',
                      onRetry: _retry,
                    ),
                  )
                else if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ..._content(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content() {
    final orders = _allOrders!;
    final totalSales = orders.fold<num>(0, (t, o) => t + adminNum(o['price']));
    final earnings = orders.fold<num>(0, (t, o) {
      final fee = o['platformFee'];
      return t + (fee is num ? fee : adminNum(o['price']) * 0.1);
    });
    final awaiting = orders.where((o) => o['status'] == 'delivered').length;

    return [
      AdminDashboardStats(
        totalSales: totalSales,
        platformEarnings: earnings,
        pendingReview: _pending!.length,
        awaitingCompletion: awaiting,
      ),
      const SizedBox(height: 18),
      _tabs(),
      const SizedBox(height: 14),
      ..._tabBody(),
      const SizedBox(height: 10),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded,
              size: 13, color: AppColors.onTertiaryContainer),
          SizedBox(width: 6),
          Text('Payouts are tracked and released by the admin',
              style: TextStyle(
                  fontSize: 11.5, color: AppColors.onTertiaryContainer)),
        ],
      ),
    ];
  }

  Widget _tabs() {
    final labels = [
      'Pending  ${_pending!.length}',
      'Orders  ${_allOrders!.length}',
      'Published  ${_published!.length}',
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == _tab ? AppColors.brandNavy : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: i == _tab
                          ? AppColors.inversePrimary.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: i == _tab ? FontWeight.w700 : FontWeight.w500,
                      color: i == _tab
                          ? Colors.white
                          : AppColors.onTertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _tabBody() {
    switch (_tab) {
      case 0:
        return _projectList(
          _pending!,
          'No projects waiting for review.',
        );
      case 2:
        return _projectList(
          _published!,
          'No published projects yet.',
        );
      default:
        return _orderList();
    }
  }

  List<Widget> _projectList(List<_Map> list, String empty) {
    if (list.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: AdminNotice(icon: Icons.inbox_outlined, text: empty),
        ),
      ];
    }
    return [
      for (final p in list)
        AdminProjectCard(project: p, onTap: () => _openReview(p)),
    ];
  }

  List<Widget> _orderList() {
    final all = _allOrders!;
    int count(String s) =>
        s == 'all' ? all.length : all.where((o) => o['status'] == s).length;

    const filters = ['all', 'paid', 'delivered', 'completed'];
    final shown = _orderFilter == 'all'
        ? all
        : all.where((o) => o['status'] == _orderFilter).toList();

    return [
      SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = filters[i];
            final sel = f == _orderFilter;
            return GestureDetector(
              onTap: () => setState(() => _orderFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryContainer
                      : AppColors.tertiaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? AppColors.inversePrimary
                        : AppColors.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${f[0].toUpperCase()}${f.substring(1)}  ${count(f)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? Colors.white : AppColors.onTertiaryContainer,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      if (shown.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: AdminNotice(
            icon: Icons.receipt_long_outlined,
            text: 'No orders in this filter.',
          ),
        )
      else
        for (final o in shown) AdminOrderCard(order: o, onTap: () => _openOrder(o)),
    ];
  }
}