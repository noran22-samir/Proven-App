import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/colors.dart';
import '../../cubit/my_project_cubit.dart';
import '../../cubit/my_project_state.dart';
import '../widgets/project_card.dart';

class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key});

  List _getFilteredProjects(MyProjectCubit cubit) {
    if (cubit.selectedIndex == 1) {
      return cubit.projects.where((p) => p['status'] == 'Pending').toList();
    } else if (cubit.selectedIndex == 2) {
      return cubit.projects.where((p) => p['status'] == 'Approved').toList();
    } else if (cubit.selectedIndex == 3) {
      return cubit.projects.where((p) => p['status'] == 'Rejected').toList();
    }
    return cubit.projects; 
  }

  //A simple dialog for editing project data using Cubit.
  void _showEditDialog(
    BuildContext context,
    MyProjectCubit cubit,
    Map project,
  ) {
    final titleController = TextEditingController(text: project['title']);
    final categoryController = TextEditingController(text: project['category']);
    final priceController = TextEditingController(text: project['price']);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.tertiaryContainer,
        title: const Text(
          'Edit Project',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: AppColors.onTertiaryContainer),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: categoryController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: AppColors.onTertiaryContainer),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: priceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: AppColors.onTertiaryContainer),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // To Edit the projects
              cubit.updateProject(
                projectId: project['id'],
                newTitle: titleController.text.trim().isEmpty
                    ? project['title']
                    : titleController.text.trim(),
                newCategory: categoryController.text.trim().isEmpty
                    ? project['category']
                    : categoryController.text.trim(),
                newPrice: priceController.text.trim().isEmpty
                    ? project['price']
                    : priceController.text.trim(),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyProjectCubit(),
      child: BlocBuilder<MyProjectCubit, MyProjectState>(
        builder: (context, state) {
          final cubit = context.read<MyProjectCubit>();

          //Calculating the number of projects for each status.
          int pendingCount = cubit.projects
              .where((p) => p['status'] == 'Pending')
              .length;
          int approvedCount = cubit.projects
              .where((p) => p['status'] == 'Approved')
              .length;
          int rejectedCount = cubit.projects
              .where((p) => p['status'] == 'Rejected')
              .length;

          final List filters = [
            {
              'title': 'All',
              'count': '${cubit.projects.length}',
              'hasDot': false,
              'dotColor': Colors.transparent,
            },
            {
              'title': 'Pending',
              'count': '$pendingCount',
              'hasDot': true,
              'dotColor': Colors.amber,
            },
            {
              'title': 'Approved',
              'count': '$approvedCount',
              'hasDot': true,
              'dotColor': Colors.green,
            },
            {
              'title': 'Rejected',
              'count': '$rejectedCount',
              'hasDot': true,
              'dotColor': Colors.red,
            },
          ];

          final displayedProjects = _getFilteredProjects(cubit);

          return Scaffold(
            backgroundColor: AppColors.tertiary,
            appBar: AppBar(
              backgroundColor: AppColors.tertiary,
              elevation: 0,
              title: Row(
                children: [
                  const Text(
                    'My Projects',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      //Displays the total number of projects
                      '${cubit.projects.length} Total',
                      style: const TextStyle(
                        color: AppColors.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                // Search button
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: ProjectSearchDelegate(cubit.projects),
                    );
                  },
                ),
              ],
            ),
            body: state is MyProjectLoading
                ? const Center(child: CircularProgressIndicator())
                : state is MyProjectError
                ? Center(
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : Column(
                    children: [
                      // Status filter bar
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filters.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            bool isSelected = cubit.selectedIndex == index;
                            var filter = filters[index];

                            return GestureDetector(
                              onTap: () => cubit.changeFilter(index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryContainer
                                      : AppColors.tertiaryContainer.withOpacity(
                                          0.5,
                                        ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.inversePrimary
                                        : AppColors.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (filter['hasDot'] == true) ...[
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: filter['dotColor'] as Color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      filter['title'] as String,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.onTertiaryContainer,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.2)
                                            : AppColors.tertiary,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        filter['count'] as String,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.onTertiaryContainer,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // List of project cards after filtering
                      Expanded(
                        child: displayedProjects.isEmpty
                            ? const Center(
                                child: Text(
                                  'No projects in this filter',
                                  style: TextStyle(
                                    color: AppColors.onTertiaryContainer,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: displayedProjects.length,
                                itemBuilder: (context, index) {
                                  var item = displayedProjects[index];
                                  String status = item['status'];

                                  // The status and them colors
                                  Color statusColor = Colors.amber;
                                  IconData coverIcon =
                                      Icons.inventory_2_outlined;
                                  if (status == 'Approved') {
                                    statusColor = Colors.green;
                                    coverIcon = Icons.shopping_bag_outlined;
                                  } else if (status == 'Rejected') {
                                    statusColor = Colors.redAccent;
                                    coverIcon = Icons.school_outlined;
                                  }

                                  return ProjectCard(
                                    title: item['title'],
                                    category: item['category'],
                                    price: item['price'],
                                    status: status,
                                    statusColor: statusColor,
                                    statusBgColor: statusColor.withOpacity(
                                      0.15,
                                    ),
                                    subText: item['subText'],
                                    subTextColor: status == 'Approved'
                                        ? Colors.green
                                        : null,
                                    coverIcon: coverIcon,
                                    rejectionReason: item['reason'],
                                    // Edit Button
                                    onEdit: () =>
                                        _showEditDialog(context, cubit, item),
                                    //The delete button (
                                    onDelete: () =>
                                        cubit.deleteProject(item['id']),
                                    // Edit & Resubmit button for rejected projects 
                                    onResubmit: status == 'Rejected'
                                        ? () {
                                            cubit.resubmitProject(item['id']);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Project resubmitted for review',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    AppColors.tertiaryContainer,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class ProjectSearchDelegate extends SearchDelegate {
  final List projects;

  ProjectSearchDelegate(this.projects);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.tertiary,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.tertiaryContainer,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = projects
        .where(
          (project) =>
              project['title'].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          results[index]['title'],
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          results[index]['status'],
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => close(context, null),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}
