import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/contract_request_card.dart';

class PurchaseRequestsScreen extends StatelessWidget {
  const PurchaseRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main screen background color using the dark theme palette
      backgroundColor: AppColors.tertiary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section: Contains screen title, creator badge, and action buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Screen main title
                            const Text(
                              'Purchase Requests',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Creator role badge indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.inversePrimary.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'CREATOR',
                                style: TextStyle(
                                  color: AppColors.inversePrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Subtitle describing the screen context
                        const Text(
                          'Escrow payouts & graduation IP sales',
                          style: TextStyle(
                            color: AppColors.onTertiaryContainer,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter and search action buttons using a helper method
                  _buildHeaderIconButton(Icons.tune, () {}),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(Icons.search, () {}),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent round icon buttons in the header
  Widget _buildHeaderIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withOpacity(0.25)),
        ),
        child: Icon(icon, color: AppColors.inversePrimary, size: 20),
      ),
    );
  }
}