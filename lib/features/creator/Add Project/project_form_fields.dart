// المسار: lib/features/creator/Add Project/project_form_fields.dart   (ملف جديد)
//
// التصنيفات + حقل Category (مع "Other" يكتب فيه الكريتور تصنيفه) + حقل السعر بـ hint.

import 'package:flutter/material.dart';
import 'add_project_palette.dart';

const kOtherCategory = 'Other';

const kProjectCategories = <String>[
  'Healthcare',
  'E-commerce',
  'Education',
  'Finance & Banking',
  'Productivity',
  'AI & Automation',
  'Booking & Scheduling',
  'CRM & Business Tools',
  'Food & Restaurants',
  'Real Estate',
  'Logistics & Delivery',
  'Travel & Tourism',
  'Games & Entertainment',
  'Social & Community',
  'HR & Recruitment',
  'Fitness & Wellness',
  'IoT & Hardware',
  kOtherCategory,
];

/// null = التصنيف المكتوب سليم
String? validateCustomCategory(String raw) {
  final t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty) return 'Write your category name.';
  if (t.length < 2 || t.length > 30) {
    return 'Category must be between 2 and 30 characters.';
  }
  if (!RegExp(r'^[\p{L}\p{N} &/\-.]+$', unicode: true).hasMatch(t)) {
    return 'Category can only have letters, numbers, spaces and & / - .';
  }
  if (!RegExp(r'\p{L}', unicode: true).hasMatch(t)) {
    return 'Category must contain letters.';
  }
  if (t.toLowerCase() == 'other') return 'Please write a more specific category.';
  return null;
}

/// ينضّف التصنيف: لو بيطابق تصنيف موجود (بغض النظر عن الحروف) بيستخدم الموجود،
/// غير كده بيكبّر أول حرف من كل كلمة.
String normalizeCategory(String raw) {
  final t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  for (final c in kProjectCategories) {
    if (c != kOtherCategory && c.toLowerCase() == t.toLowerCase()) return c;
  }
  return t
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      dropdownColor: AppColors.surface,
      menuMaxHeight: 360,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
      items: [
        for (final c in kProjectCategories)
          DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

class PriceInput extends StatelessWidget {
  const PriceInput({super.key, required this.controller, this.enabled = true});
  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 61,
            height: double.infinity,
            color: const Color(0xFF173B56),
            alignment: Alignment.center,
            child: const Text('EGP',
                style: TextStyle(
                    color: AppColors.primaryBright, fontWeight: FontWeight.w700)),
          ),
          Container(width: 1, height: double.infinity, color: AppColors.border),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 8500  (100 - 100,000)',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}