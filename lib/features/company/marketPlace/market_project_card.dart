// المسار: lib/features/company/marketPlace/market_project_card.dart   (ملف جديد)
//
// كارت المشروع في الـ Market بصورة حقيقية. في market_page.dart:
//   1) ضيف import للملف ده + import 'package:proven/features/projects/project_cover.dart' مش لازم
//   2) استبدل _ProjectCard(...) بـ MarketProjectCard(...) بنفس الـ parameters
//   3) امسح كلاس _ProjectCard القديم

import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/projects/project_cover.dart';
import 'package:proven/features/projects/projects_repository.dart';

class MarketProjectCard extends StatelessWidget {
  const MarketProjectCard({
    super.key,
    required this.project,
    required this.price,
    required this.onTap,
  });

  final Map<String, dynamic> project;
  final num price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = '${project['category'] ?? ''}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProjectCover(url: ProjectCover.firstImage(project['images'])),
                  if (category.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: AppColors.inversePrimary)),
                        ),
                      ),
                    ),
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.verified_rounded, size: 16, color: Color(0xFF34D399)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${project['title'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${project['description'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.onTertiaryContainer)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(ProjectsRepository.egp(price),
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF2B84B))),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.brandNavy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}