// المسار: lib/features/creator/my_project/presentation/screens/my_project_screen.dart   (بدّل الملف كله)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../../cubit/my_project_cubit.dart';
import '../../cubit/my_project_state.dart';
import '../widgets/edit_project_sheet.dart';
import '../widgets/project_card.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key, this.onAddProject});

  /// زرار "Add your first project" بيقلب لتاب Add في الـ shell
  final VoidCallback? onAddProject;

  static const _titles = ['All', 'Pending', 'Approved', 'Rejected'];
  static const _dots = <Color?>[null, Colors.amber, Colors.green, Colors.red];

  static Color _statusColor(String s) {
    switch (s) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.redAccent;
      case 'Archived':
        return Colors.grey;
      case 'Unpublished':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  List<Map<String, dynamic>> _visible(MyProjectCubit c) {
    if (c.selectedIndex == 0) return c.projects;
    final s = _titles[c.selectedIndex];
    return c.projects.where((p) => p['status'] == s).toList();
  }

  int _count(MyProjectCubit c, int filter) => filter == 0
      ? c.projects.length
      : c.projects.where((p) => p['status'] == _titles[filter]).length;

  Future<bool> _confirmDelete(BuildContext context, String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.tertiaryContainer,
        title: const Text('Delete project?'),
        content: Text('"$title" will be removed permanently. This can not be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyProjectCubit(),
      child: BlocBuilder<MyProjectCubit, MyProjectState>(
        builder: (context, state) {
          final cubit = context.read<MyProjectCubit>();

          return Scaffold(
            backgroundColor: AppColors.tertiary,
            appBar: AppBar(
              backgroundColor: AppColors.tertiary,
              title: Row(
                children: [
                  const Text('My Projects',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${cubit.projects.length} Total',
                        style: const TextStyle(
                            color: AppColors.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: ProjectSearchDelegate(cubit.projects),
                  ),
                ),
              ],
            ),
            body: _body(context, cubit, state),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, MyProjectCubit cubit, MyProjectState state) {
    if (state is MyProjectLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is MyProjectError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(state.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onTertiaryContainer)),
        ),
      );
    }

    if (cubit.projects.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rocket_launch_outlined, size: 56, color: AppColors.inversePrimary),
              const SizedBox(height: 14),
              const Text('No projects yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                'Add your graduation project and companies can start buying it after admin review.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onTertiaryContainer, height: 1.4),
              ),
              if (onAddProject != null) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onAddProject,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add your first project'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.brandNavy),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final shown = _visible(cubit);

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            itemCount: _titles.length,
            itemBuilder: (_, i) => _FilterChip(
              title: _titles[i],
              count: _count(cubit, i),
              dot: _dots[i],
              selected: cubit.selectedIndex == i,
              onTap: () => cubit.changeFilter(i),
            ),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? const Center(
                  child: Text('No projects in this filter',
                      style: TextStyle(color: AppColors.onTertiaryContainer)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: shown.length,
                  itemBuilder: (context, i) {
                    final item = shown[i];
                    final status = '${item['status']}';
                    final color = _statusColor(status);

                    return ProjectCard(
                      title: item['title'],
                      category: item['category'],
                      price: item['price'],
                      status: status,
                      statusColor: color,
                      statusBgColor: color.withValues(alpha: 0.15),
                      subText: item['subText'],
                      subTextColor: status == 'Approved' ? Colors.green : null,
                      coverIcon: Icons.inventory_2_outlined,
                      imageUrl: item['image'],
                      rejectionReason: item['reason'],
                      onEdit: () => EditProjectSheet.show(context, cubit, item),
                      onResubmit: status == 'Rejected'
                          ? () => EditProjectSheet.show(context, cubit, item)
                          : null,
                      onDelete: () async {
                        final ok = await _confirmDelete(context, '${item['title']}');
                        if (!ok || !context.mounted) return;
                        final err = await cubit.deleteProject(item['id']);
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(err)));
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.count,
    required this.dot,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final int count;
  final Color? dot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.tertiaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? AppColors.inversePrimary
                : AppColors.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(title,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.tertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.onTertiaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectSearchDelegate extends SearchDelegate {
  ProjectSearchDelegate(this.projects);
  final List<Map<String, dynamic>> projects;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.tertiary,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.tertiaryContainer),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase();
    final results = projects
        .where((p) => '${p['title']}'.toLowerCase().contains(q))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No matching projects',
            style: TextStyle(color: AppColors.onTertiaryContainer)),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(
        title: Text('${results[i]['title']}'),
        subtitle: Text('${results[i]['status']}',
            style: const TextStyle(color: AppColors.onTertiaryContainer)),
        trailing: Text('${results[i]['price']}',
            style: const TextStyle(color: AppColors.inversePrimary)),
        onTap: () => close(context, null),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}