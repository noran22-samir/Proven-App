import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/project_card.dart';
import '../../../Add Project/add_project_page.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  int selectedFilterIndex = 0;

  final List filters = [
    {
      'title': 'All',
      'count': '3',
      'hasDot': false,
      'dotColor': Colors.transparent,
    },
    {
      'title': 'Pending',
      'count': '1',
      'hasDot': true,
      'dotColor': Colors.amber,
    },
    {
      'title': 'Approved',
      'count': '1',
      'hasDot': true,
      'dotColor': Colors.green,
    },
    {'title': 'Rejected', 'count': '1', 'hasDot': true, 'dotColor': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '3 Total',
                style: TextStyle(
                  color: AppColors.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(context: context, delegate: ProjectSearchDelegate());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Filter Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                bool isSelected = selectedFilterIndex == index;
                var filter = filters[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilterIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.tertiaryContainer.withOpacity(0.5),
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
          // List of Project Cards matching the design image exactly
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Pending Project
                ProjectCard(
                  title: 'ClinicFlow',
                  category: 'Healthcare',
                  price: '8,500 EGP',
                  status: 'Pending',
                  statusColor: Colors.amber,
                  statusBgColor: Colors.amber.withOpacity(0.15),
                  subText: 'Submitted 2d ago',
                  coverIcon: Icons.inventory_2_outlined,
                  onEdit: () {},
                  onDelete: () {},
                ),
                // 2. Approved Project
                ProjectCard(
                  title: 'ShopLite',
                  category: 'E-Commerce',
                  price: '6,200 EGP',
                  status: 'Approved',
                  statusColor: Colors.green,
                  statusBgColor: Colors.green.withOpacity(0.15),
                  subText: 'Live on Marketplace',
                  subTextColor: Colors.green,
                  coverIcon: Icons.shopping_bag_outlined,
                  onEdit: () {},
                  onDelete: () {},
                ),
                // 3. Rejected Project with Rejection Box & Resubmit Button
                ProjectCard(
                  title: 'EduTrack',
                  category: 'EdTech',
                  price: '4,800 EGP',
                  status: 'Rejected',
                  statusColor: Colors.redAccent,
                  statusBgColor: Colors.redAccent.withOpacity(0.15),
                  subText: 'Needs Revision',
                  coverIcon: Icons.school_outlined,
                  rejectionReason: 'Please add a working demo link.',
                  onEdit: () {},
                  onDelete: () {},
                  onResubmit: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit & Resubmit clicked',
                        style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppColors.tertiaryContainer,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectSearchDelegate extends SearchDelegate {
  final List projects = [
    {'title': 'ClinicFlow', 'status': 'Pending'},
    {'title': 'ShopLite', 'status': 'Approved'},
    {'title': 'EduTrack', 'status': 'Rejected'},
  ];

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
              project['title']!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          results[index]['title']!,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          results[index]['status']!,
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => close(context, null),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}
