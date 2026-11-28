// المسار: lib/features/creator/Add Project/picked_images_grid.dart   (ملف جديد)
//
// بديل ProjectImageGrid الوهمي: بيعرض الصور اللي اختارها الكريتور فعلاً،
// وبيدّيه زرار إضافة وزرار حذف لكل صورة. (الكلاس القديم ProjectImageGrid بقى مش مستخدم.)

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'add_project_components.dart' show DashedBorderPainter, ImageChip;
import 'add_project_palette.dart';

class PickedImagesGrid extends StatelessWidget {
  const PickedImagesGrid({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.enabled = true,
  });

  static const maxImages = 4;

  final List<Uint8List> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: maxImages,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, i) {
        if (i < images.length) return _filled(i);
        return _empty();
      },
    );
  }

  Widget _filled(int i) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(images[i], fit: BoxFit.cover, gaplessPlayback: true),
          if (i == 0)
            const Positioned(top: 10, left: 10, child: ImageChip('Cover')),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: enabled ? () => onRemove(i) : null,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xDD02070C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return GestureDetector(
      onTap: enabled ? onAdd : null,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.border.withValues(alpha: 0.9),
          radius: 15,
        ),
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.muted,
            size: 26,
          ),
        ),
      ),
    );
  }
}