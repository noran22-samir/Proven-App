// المسار: lib/features/creator/my_project/presentation/widgets/edit_project_sheet.dart   (ملف جديد)
//
// شاشة تعديل المشروع (Bottom Sheet): عنوان، وصف، تصنيف (قائمة + Other)، سعر، تقنيات.
// بتستخدم نفس حقول Add Project. الحفظ بيبعت المشروع للمراجعة تاني.

import 'package:flutter/material.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/creator/Add Project/project_form_fields.dart';
import '../../cubit/my_project_cubit.dart';

class EditProjectSheet extends StatefulWidget {
  const EditProjectSheet({super.key, required this.cubit, required this.item});

  final MyProjectCubit cubit;
  final Map item;

  static Future<void> show(BuildContext context, MyProjectCubit cubit, Map item) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.tertiaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditProjectSheet(cubit: cubit, item: item),
    );
  }

  @override
  State<EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends State<EditProjectSheet> {
  late final _title = TextEditingController(text: '${widget.item['title'] ?? ''}');
  late final _description =
      TextEditingController(text: '${widget.item['description'] ?? ''}');
  late final _price = TextEditingController(
    text: widget.item['priceValue'] is num
        ? (widget.item['priceValue'] as num).round().toString()
        : '',
  );
  late final _tech = TextEditingController(
    text: (widget.item['techStack'] is List)
        ? (widget.item['techStack'] as List).join(', ')
        : '',
  );
  final _other = TextEditingController();

  late String _category;
  bool _saving = false;
  String? _error;

  bool get _isLive => widget.item['status'] == 'Approved';

  @override
  void initState() {
    super.initState();
    final c = '${widget.item['category'] ?? ''}';
    if (kProjectCategories.contains(c) && c != kOtherCategory) {
      _category = c;
    } else {
      _category = kOtherCategory;
      _other.text = c;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _tech.dispose();
    _other.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    var category = _category;
    if (_category == kOtherCategory) {
      final err = validateCustomCategory(_other.text);
      if (err != null) {
        setState(() => _error = err);
        return;
      }
      category = normalizeCategory(_other.text);
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });

    final err = await widget.cubit.updateProject(
      projectId: '${widget.item['id']}',
      title: _title.text,
      description: _description.text,
      category: category,
      priceText: _price.text,
      techStack: _tech.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
    if (!mounted) return;

    if (err == null) {
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Saved. Your project was sent for review.')),
      );
    } else {
      setState(() {
        _saving = false;
        _error = err;
      });
    }
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(fontSize: 13, color: AppColors.onTertiaryContainer)),
      );

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + (insets > 0 ? insets : safeBottom)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Edit project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1C65D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1C65D).withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFF1C65D)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isLive
                          ? 'This project is live. Saving changes hides it from the market until the admin approves it again.'
                          : 'Saving sends the project to the admin for review.',
                      style: const TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _label('Title'),
            TextField(
              controller: _title,
              enabled: !_saving,
              maxLength: 80,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Description'),
            TextField(
              controller: _description,
              enabled: !_saving,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(counterText: ''),
            ),
            const SizedBox(height: 14),
            _label('Category'),
            CategoryDropdown(
              value: _category,
              enabled: !_saving,
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            if (_category == kOtherCategory) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _other,
                enabled: !_saving,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Write your category',
                  counterText: '',
                ),
              ),
            ],
            const SizedBox(height: 14),
            _label('Price'),
            PriceInput(controller: _price, enabled: !_saving),
            const SizedBox(height: 14),
            _label('Tech stack (comma separated)'),
            TextField(
              controller: _tech,
              enabled: !_saving,
              decoration: const InputDecoration(hintText: 'Flutter, Firebase'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Images and links can not be changed here yet.',
              style: TextStyle(fontSize: 11.5, color: AppColors.onTertiaryContainer),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFFF8A80))),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Save & send for review',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}