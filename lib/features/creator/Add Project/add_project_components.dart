import 'package:flutter/material.dart';
import 'app_theme.dart';

class AddProjectTopBar extends StatelessWidget {
  const AddProjectTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 14),
        const Text('Add Project', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
        const Spacer(),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBright,
            side: const BorderSide(color: AppColors.border),
            backgroundColor: AppColors.field,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          ),
          child: const Text('Creator Mode', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

class ReviewNotice extends StatelessWidget {
  const ReviewNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.amberSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.amber.withOpacity(.48)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your project will be reviewed by the admin before it appears.',
              style: TextStyle(color: AppColors.amber.withOpacity(.92), height: 1.45, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class FormSectionHeading extends StatelessWidget {
  const FormSectionHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('GENERAL INFORMATION', style: TextStyle(color: AppColors.muted, letterSpacing: 1.5, fontWeight: FontWeight.w700, fontSize: 13)),
        const Spacer(),
        Text('* Required fields', style: TextStyle(color: AppColors.muted.withOpacity(.8), fontSize: 11)),
      ],
    );
  }
}

class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key, this.requiredField = false, this.counter});
  final String text;
  final bool requiredField;
  final String? counter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        if (requiredField) const Text(' *', style: TextStyle(color: AppColors.amber)),
        if (counter != null) ...[
          const Spacer(),
          Text(counter!, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ],
    );
  }
}

class CategoryField extends StatelessWidget {
  const CategoryField({super.key, required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surface,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
      items: const ['Healthcare', 'Education', 'Finance', 'Productivity']
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class PriceField extends StatelessWidget {
  const PriceField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(color: AppColors.field, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(width: 61, height: double.infinity, color: const Color(0xFF173B56), alignment: Alignment.center, child: const Text('EGP', style: TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.w700))),
          Container(width: 1, height: double.infinity, color: AppColors.border),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectImagesHeading extends StatelessWidget {
  const ProjectImagesHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const FormLabel('Project images', requiredField: true),
        const Spacer(),
        const Text('Up to 4 images', style: TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    );
  }
}

class ProjectImageGrid extends StatelessWidget {
  const ProjectImageGrid({super.key, required this.imageCount, required this.onSlotTap});
  final int imageCount;
  final ValueChanged<int> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.45),
      itemBuilder: (_, index) {
        final hasImage = index < imageCount;
        return GestureDetector(
          onTap: () => onSlotTap(index),
          child: Container(
            decoration: BoxDecoration(color: hasImage ? const Color(0xFF182754) : Colors.transparent, borderRadius: BorderRadius.circular(15), border: Border.all(color: hasImage ? AppColors.border : AppColors.border.withOpacity(.75), style: hasImage ? BorderStyle.solid : BorderStyle.none)),
            child: hasImage
                ? Stack(children: [
                    Center(child: Icon(Icons.image_outlined, color: AppColors.primaryBright.withOpacity(.85), size: 30)),
                    if (index == 0) const Positioned(top: 10, left: 10, child: ImageChip('Cover')),
                    const Positioned(top: 9, right: 9, child: ImageCloseButton()),
                  ])
                : CustomPaint(painter: DashedBorderPainter(color: AppColors.border.withOpacity(.9), radius: 15), child: const Center(child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.muted, size: 26))),
          ),
        );
      },
    );
  }
}

class ImageChip extends StatelessWidget {
  const ImageChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF1C6E9C), borderRadius: BorderRadius.circular(5)), child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)));
}

class ImageCloseButton extends StatelessWidget {
  const ImageCloseButton({super.key});

  @override
  Widget build(BuildContext context) => Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xDD02070C), shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 17));
}

class VerificationLinks extends StatelessWidget {
  const VerificationLinks({super.key, required this.demoController, required this.githubController});
  final TextEditingController demoController;
  final TextEditingController githubController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VERIFICATION LINKS (OPTIONAL)', style: TextStyle(color: AppColors.muted, letterSpacing: 1.25, fontWeight: FontWeight.w700, fontSize: 11)),
        const SizedBox(height: 12),
        _LinkField(label: 'Demo link (optional)', controller: demoController, hint: 'https://your-demo-link.com'),
        const SizedBox(height: 12),
        _LinkField(label: 'GitHub link (optional)', controller: githubController, hint: 'https://github.com/username/repository'),
      ],
    );
  }
}

class _LinkField extends StatelessWidget {
  const _LinkField({required this.label, required this.controller, required this.hint});
  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(controller: controller, keyboardType: TextInputType.url, textInputAction: TextInputAction.next, style: const TextStyle(fontSize: 12), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
    ]);
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.submitted, required this.onPressed});
  final bool submitted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(submitted ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 20),
        label: Text(submitted ? 'Submitted for Review' : 'Submit for Review', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.text, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: AppColors.primaryBright, width: .5))),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 10) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) => oldDelegate.color != color || oldDelegate.radius != radius;
}
