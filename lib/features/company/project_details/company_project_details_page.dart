// PATH: lib/features/company/project_details/company_project_details_page.dart
// ACTION: NEW file. Same folder as the old test.dart (that one is the ADMIN review page,
//         keep it for now, we will use it for the admin).
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/company/checkout/checkout_page.dart';
import 'package:proven/features/orders/orders_repository.dart';
import 'package:proven/features/projects/projects_repository.dart';

const _gold = Color(0xFFF2B84B);
const _green = Color(0xFF34D399);

class _Loaded {
  const _Loaded(this.project, this.purchased);
  final Map<String, dynamic>? project;
  final bool purchased;
}

class CompanyProjectDetailsPage extends StatefulWidget {
  const CompanyProjectDetailsPage({
    super.key,
    required this.projectId,
    this.onViewOrders,
  });

  final String projectId;

  final VoidCallback? onViewOrders;

  @override
  State<CompanyProjectDetailsPage> createState() =>
      _CompanyProjectDetailsPageState();
}

class _CompanyProjectDetailsPageState extends State<CompanyProjectDetailsPage> {
  final _projects = ProjectsRepository();
  final _orders = OrdersRepository();
  late Future<_Loaded> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Loaded> _load() async {
    final p = await _projects.getById(widget.projectId);
    final bought = p == null
        ? false
        : await _orders.hasPurchased(widget.projectId);
    return _Loaded(p, bought);
  }

  void _reload() => setState(() {
    _future = _load();
  });
  Future<void> _buy(String title, num price, String ownerName, String imageUrl) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (checkoutContext) => CheckoutScreen(
          projectTitle: title,
          developerName: ownerName,
          price: price.toInt(),
          imageUrl: imageUrl.startsWith('http') ? imageUrl : null,
          onBack: () => Navigator.of(checkoutContext).pop(),
          onPaid: (transactionId) => _createOrder(),
          onBackToMarketplace: () {
            Navigator.of(checkoutContext).pop();
            if (mounted) Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<String?> _createOrder() async {
    try {
      await _orders.buy(widget.projectId);
      if (mounted) _reload();
      return null;
    } on OrderException catch (e) {
      return switch (e.code) {
        'already-purchased' => 'You already bought this project.',
        'project-unavailable' => 'This project is no longer available.',
        _ => 'Please log in again.',
      };
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied'
          ? 'Only company accounts can buy projects.'
          : 'Could not complete the payment. Check your internet.';
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      appBar: AppBar(title: const Text('Project details')),
      body: FutureBuilder<_Loaded>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data?.project == null) {
            return _Notice(
              icon: Icons.inventory_2_outlined,
              text: snap.hasError
                  ? 'Could not load this project.\nIt may no longer be available.'
                  : 'Project not found.',
              onRetry: _reload,
            );
          }
          return _content(snap.data!.project!, snap.data!.purchased);
        },
      ),
    );
  }

  Widget _content(Map<String, dynamic> p, bool purchased) {
    String s(String k) => (p[k] ?? '').toString().trim();
    final price = p['price'] is num ? p['price'] as num : 0;
    final images = p['images'] is List ? p['images'] as List : const [];
    final tech = p['techStack'] is List
        ? (p['techStack'] as List).map((e) => '$e').toList()
        : <String>[];
    final title = s('title');

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _cover(images.isEmpty ? '' : '${images.first}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Chip(s('category'), AppColors.inversePrimary),
                  const SizedBox(width: 8),
                  const _Chip(
                    'Admin verified',
                    _green,
                    icon: Icons.verified_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColors.onTertiaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'By ${s('ownerName').isEmpty ? 'Creator' : s('ownerName')}',
                    style: const TextStyle(
                      color: AppColors.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Box(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRICE',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1,
                              color: AppColors.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ProjectsRepository.egp(price),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _license(s('licenseType')),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.inversePrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Escrow protected payment',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Box(
                title: 'Description',
                child: Text(
                  s('description').isEmpty ? '—' : s('description'),
                  style: TextStyle(
                    height: 1.55,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ),
              if (tech.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Box(
                  title: 'Tech stack',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in tech) _Chip(t, AppColors.inversePrimary),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _Box(
                title: 'Links',
                child: Column(
                  children: [
                    _LinkRow(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Live demo',
                      url: s('demoLink'),
                      emptyText: 'No demo link',
                    ),
                    const Divider(height: 20),
                    _LinkRow(
                      icon: Icons.code_rounded,
                      label: 'Source code',
                      url: purchased ? s('githubLink') : '',
                      emptyText: purchased
                          ? 'No source link'
                          : 'Unlocked after purchase',
                      locked: !purchased,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buyBar(
          title,
          price,
          purchased,
          s('ownerName').isEmpty ? 'Creator' : s('ownerName'),
          images.isEmpty ? '' : '${images.first}',
        ),
      ],
    );
  }

  Widget _buyBar(
    String title,
    num price,
    bool purchased,
    String ownerName,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.25)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: purchased
              ? OutlinedButton.icon(
                  onPressed: widget.onViewOrders == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          widget.onViewOrders!();
                        },
                  icon: const Icon(Icons.check_circle_rounded, color: _green),
                  label: const Text('Purchased · View my orders'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: BorderSide(color: _green.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: () => _buy(title, price, ownerName, imageUrl),
                  icon: const Icon(Icons.lock_outline_rounded, size: 20),
                  label: Text(
                    'Buy now · ${ProjectsRepository.egp(price)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _cover(String url) {
    Widget placeholder() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.lock_outline_rounded,
          size: 44,
          color: AppColors.inversePrimary,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: url.startsWith('http')
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder(),
              )
            : placeholder(),
      ),
    );
  }

  static String _license(String raw) {
    switch (raw) {
      case 'turnkey':
        return 'Turnkey license';
      case 'source':
        return 'Includes source code';
      case 'enterprise':
        return 'Enterprise ready';
      default:
        return raw.isEmpty ? 'Standard license' : raw;
    }
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child, this.title});
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color, {this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.url,
    required this.emptyText,
    this.locked = false,
  });

  final IconData icon;
  final String label;
  final String url;
  final String emptyText;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final has = url.isNotEmpty;
    return Row(
      children: [
        Icon(
          locked ? Icons.lock_outline_rounded : icon,
          size: 20,
          color: AppColors.inversePrimary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.onTertiaryContainer,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                has ? url : emptyText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  color: has
                      ? Colors.white
                      : AppColors.onTertiaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (has)
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: AppColors.inversePrimary,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Link copied')));
            },
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.text,
    required this.onRetry,
  });
  final IconData icon;
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.onTertiaryContainer),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onTertiaryContainer),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}