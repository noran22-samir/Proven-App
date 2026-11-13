import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/project_card.dart';



class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  int selectedFilterIndex = 0;

  final List<Map<String, Object>> filters = [
    {'title': 'All', 'count': '3', 'hasDot': false, 'dotColor': Colors.transparent},
    {'title': 'Pending', 'count': '1', 'hasDot': true, 'dotColor': Colors.amber},
    {'title': 'Approved', 'count': '1', 'hasDot': true, 'dotColor': Colors.green},
    {'title': 'Rejected', 'count': '0', 'hasDot': true, 'dotColor': Colors.red},
  ];
@override
  Widget build(BuildContext context) {
    return Scaffold(
      // The dark background color for the new design from the AppColors file
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
                '3',
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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal filter bar consistent with the dark theme
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      // A light, prominent blue when selected, and a subtle, dark background when not selected.
                      color: isSelected ? AppColors.primaryContainer : AppColors.tertiaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? AppColors.inversePrimary : AppColors.outline.withOpacity(0.3),
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
                            color: isSelected ? Colors.white : AppColors.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : AppColors.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            filter['count'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.onTertiaryContainer,
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
          // List of project cards in the dark theme
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ProjectCard(
                  status: 'Approved',
                  statusColor: Colors.green,
                  title: 'ClinicFlow - Intelligent Clinic Manager',
                  description: 'Full-stack Next.js and Flutter platform for clinic scheduling...',
                  category: 'Healthcare',
                  price: '8,500 EGP',
                  views: '342 views',
                  inquiries: '14 inquiries',
                ),
                ProjectCard(
                  status: 'Pending Review',
                  statusColor: Colors.amber,
                  title: 'ShopLite - Modern E-Commerce',
                  description: 'Retail platform with advanced shopping cart...',
                  category: 'Retail',
                  price: '6,000 EGP',
                  views: '120 views',
                  inquiries: '5 inquiries',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}