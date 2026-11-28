// المسار: lib/features/projects/project_cover.dart   (ملف جديد)
//
// بيعرض أول صورة للمشروع من رابط Cloudinary (مصغّرة وسريعة)، ولو مفيش صورة
// أو الرابط 'placeholder' (مشاريع قديمة) أو حصل خطأ، بيعرض أيقونة بدلها.

import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';

class ProjectCover extends StatelessWidget {
  const ProjectCover({
    super.key,
    required this.url,
    this.icon = Icons.image_outlined,
    this.thumbWidth = 600,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final IconData icon;
  final int thumbWidth;
  final BoxFit fit;

  /// أول رابط http صالح من حقل images
  static String? firstImage(dynamic images) {
    if (images is List) {
      for (final e in images) {
        final s = '$e';
        if (s.startsWith('http')) return s;
      }
    }
    return null;
  }

  /// يطلب من Cloudinary نسخة أصغر (أسرع وأوفر في النت)
  static String thumb(String url, int width) {
    const marker = '/upload/';
    if (!url.contains('res.cloudinary.com') || !url.contains(marker)) return url;
    return url.replaceFirst(marker, '$marker' 'w_$width,c_limit,q_auto,f_auto/');
  }

  Widget _placeholder() => Container(
        color: AppColors.tertiary,
        alignment: Alignment.center,
        child: Icon(icon, size: 30, color: AppColors.inversePrimary.withValues(alpha: 0.7)),
      );

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || !u.startsWith('http')) return _placeholder();
    return Image.network(
      thumb(u, thumbWidth),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder(),
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }
}