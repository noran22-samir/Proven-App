// PATH: lib/features/company/marketPlace/market_page.dart
// ACTION: REPLACE the existing file (same place).
import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/projects/projects_repository.dart';
import 'package:proven/features/company/marketPlace/market_project_card.dart';
typedef _Project = Map<String, dynamic>;

class MarketPage extends StatefulWidget {
  const MarketPage({super.key, this.onOpenMatchmaker, this.onOpenProject});
  final ValueChanged<String>? onOpenProject;

  /// "Try it" on the AI banner: the shell switches to the Matchmaker tab.
  final VoidCallback? onOpenMatchmaker;

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _repo = ProjectsRepository();
  late final Stream<List<_Project>> _stream = _repo.approvedProjects();
  final _search = TextEditingController();

  String _query = '';
  String _category = 'All';
  int _sort = 0; // 0 newest, 1 price low-high, 2 price high-low

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  num _price(_Project p) => p['price'] is num ? p['price'] as num : 0;

  List<_Project> _apply(List<_Project> all) {
    final q = _query.trim().toLowerCase();
    final out = all.where((p) {
      if (_category != 'All' && '${p['category']}' != _category) return false;
      if (q.isEmpty) return true;
      return '${p['title']} ${p['description']} ${p['category']}'
          .toLowerCase()
          .contains(q);
    }).toList();
    if (_sort == 1) out.sort((a, b) => _price(a).compareTo(_price(b)));
    if (_sort == 2) out.sort((a, b) => _price(b).compareTo(_price(a)));
    return out;
  }

  void _open(_Project p) => widget.onOpenProject?.call('${p['id']}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: StreamBuilder<List<_Project>>(
                stream: _stream,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const _Notice(
                      icon: Icons.cloud_off_rounded,
                      text: 'Could not load projects.\nCheck your internet.',
                    );
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data!;
                  final cats = <String>{
                    for (final p in all)
                      if ('${p['category']}'.isNotEmpty) '${p['category']}',
                  }.toList()..sort();
                  final shown = _apply(all);

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _chips(['All', ...cats])),
                      SliverToBoxAdapter(child: _banner()),
                      SliverToBoxAdapter(child: _sectionTitle(shown.length)),
                      if (shown.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _Notice(
                            icon: Icons.inventory_2_outlined,
                            text: 'No approved projects match yet.',
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.78,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => MarketProjectCard(
                                project: shown[i],
                                price: _price(shown[i]),
                                onTap: () => _open(shown[i]),
                              ),
                              childCount: shown.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        border: Border(
          bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.25)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'PROVEN',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.onPrimaryFixed,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.inversePrimary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'COMPANY',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryFixedDim,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Find your next project',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: SearchBar(
                    controller: _search,
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: const WidgetStatePropertyAll(
                      AppColors.tertiary,
                    ),
                    hintText: 'Search projects, e.g. booking system',
                    hintStyle: const WidgetStatePropertyAll(
                      TextStyle(
                        color: AppColors.onPrimaryContainer,
                        fontSize: 13,
                      ),
                    ),
                    leading: const Icon(
                      Icons.search_rounded,
                      color: AppColors.onPrimaryContainer,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<int>(
                tooltip: 'Sort',
                color: AppColors.tertiaryContainer,
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 0, child: Text('Newest')),
                  PopupMenuItem(value: 1, child: Text('Price: low to high')),
                  PopupMenuItem(value: 2, child: Text('Price: high to low')),
                ],
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chips(List<String> cats) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = cats[i] == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = cats[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.brandNavy
                    : AppColors.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel
                      ? AppColors.inversePrimary.withValues(alpha: 0.6)
                      : AppColors.outline.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                cats[i],
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
    );
  }

  Widget _banner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.inversePrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.inversePrimary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'AI MATCHMAKER',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Not sure what you need? Ask our AI Matchmaker.',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: widget.onOpenMatchmaker,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.inversePrimary,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Try it',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Text(
            'Approved projects',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.inversePrimary,
              ),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.verified_rounded,
            size: 14,
            color: AppColors.inversePrimary,
          ),
          const SizedBox(width: 4),
          const Text(
            'Verified IP',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}


class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.onTertiaryContainer),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onTertiaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
