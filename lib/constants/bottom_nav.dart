import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/user_bottom_nav.dart';


class FixedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  final List<BottomNavModel> items ;

  const FixedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        color: AppColors.tertiary,
       
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _item(index, items[index].icon, items[index].title),
            )
          ),
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Colors.white : AppColors.onTertiaryContainer;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}