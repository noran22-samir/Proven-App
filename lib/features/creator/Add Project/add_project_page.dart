// lib/features/creator/Add Project/add_project_page.dart   (بدّل الملف كله)
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proven/features/projects/cloudinary_service.dart';
import 'package:proven/features/projects/projects_repository.dart';
import 'add_project_components.dart';
import 'add_project_palette.dart';
import 'picked_images_grid.dart';
import 'project_form_fields.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _repo = ProjectsRepository();
  final _cloudinary = CloudinaryService();
  final _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _techController = TextEditingController();
  final _demoLinkController = TextEditingController();
  final _githubLinkController = TextEditingController();

  final _otherCategoryController = TextEditingController();
  String _category = kProjectCategories.first;
  final List<Uint8List> _images = []; // الصور المختارة (لسه متترفعتش)
  bool _submitted = false;
  bool _saving = false;
  String _status = '';

  static const _maxImageBytes = 8 * 1024 * 1024; // Cloudinary free: 10MB

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _techController.dispose();
    _demoLinkController.dispose();
    _githubLinkController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  // 1) اختيار الصور من المعرض (بدون رفع لسه)
  Future<void> _pickImages() async {
    final remaining = PickedImagesGrid.maxImages - _images.length;
    if (remaining <= 0) {
      _snack('You can add up to ${PickedImagesGrid.maxImages} images.');
      return;
    }
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 80, // ضغط قبل الرفع
        maxWidth: 1600,
      );
      if (files.isEmpty) return;

      final bytes = await Future.wait(
        files.take(remaining).map((f) => f.readAsBytes()),
      );
      final ok = bytes.where((b) => b.lengthInBytes <= _maxImageBytes).toList();
      if (ok.length < bytes.length) _snack('Some images were too large (max 8 MB).');
      if (!mounted) return;
      setState(() => _images.addAll(ok));
    } catch (_) {
      if (mounted) _snack('Could not open your gallery.');
    }
  }

  // 2) رفع الصور لـ Cloudinary ثم حفظ الروابط في Firestore
  Future<void> _submit() async {
    if (_saving) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final price = num.tryParse(_priceController.text.replaceAll(',', '').trim());

    if (title.isEmpty || desc.isEmpty) {
      _snack('Please fill the title and description.');
      return;
    }
    var category = _category;
    if (_category == kOtherCategory) {
      final err = validateCustomCategory(_otherCategoryController.text);
      if (err != null) {
        _snack(err);
        return;
      }
      category = normalizeCategory(_otherCategoryController.text);
    }
    if (price == null ||
        price < ProjectsRepository.minPrice ||
        price > ProjectsRepository.maxPrice) {
      _snack('Price must be between 100 and 100,000 EGP.');
      return;
    }
    if (_images.isEmpty) {
      _snack('Add at least one project image.');
      return;
    }

    setState(() {
      _saving = true;
      _status = 'Uploading images…';
    });
    try {
      final urls = await _cloudinary.uploadAll(_images);

      if (!mounted) return;
      setState(() => _status = 'Saving project…');

      await _repo.submit(
        title: title,
        description: desc,
        category: category,
        price: price,
        images: urls, // روابط Cloudinary
        techStack: _techController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        demoLink: _demoLinkController.text.trim(),
        githubLink: _githubLinkController.text.trim(),
      );
      if (!mounted) return;

      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _techController.clear();
      _demoLinkController.clear();
      _githubLinkController.clear();
      _otherCategoryController.clear();
      setState(() {
        _images.clear();
        _category = kProjectCategories.first;
        _submitted = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _submitted = false);
      });
      _snack('Project submitted for review');
    } on CloudinaryException catch (e) {
      if (mounted) _snack(e.message);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _snack(
        e.code == 'permission-denied'
            ? 'You are not allowed to add projects. Log in as a creator.'
            : 'Could not submit. Check your internet and try again.',
      );
    } catch (_) {
      if (mounted) _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 620 ? 40.0 : 20.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const AddProjectTopBar(),
                          const SizedBox(height: 22),
                          const ReviewNotice(),
                          const SizedBox(height: 28),
                          const FormSectionHeading(),
                          const SizedBox(height: 22),
                          const FormLabel('Project title', requiredField: true),
                          const SizedBox(height: 8),
                          TextField(controller: _titleController, enabled: !_saving, maxLength: 80, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'e.g. ClinicFlow - Clinic Booking System', counterText: '')),
                          const SizedBox(height: 22),
                          FormLabel('Description', requiredField: true, counter: '${_descriptionController.text.length} / 1000'),
                          const SizedBox(height: 8),
                          TextField(controller: _descriptionController, enabled: !_saving, maxLines: 4, maxLength: 1000, decoration: const InputDecoration(hintText: 'What does it do? Who is it for? Main features, the tech used, and what the buyer receives (source code, docs, support)...'), onChanged: (_) => setState(() {}), buildCounter: (_, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink()),
                          const SizedBox(height: 22),
                          const FormLabel('Category', requiredField: true),
                          const SizedBox(height: 8),
                          CategoryDropdown(value: _category, enabled: !_saving, onChanged: (v) => setState(() => _category = v ?? _category)),
                          if (_category == kOtherCategory) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _otherCategoryController,
                              enabled: !_saving,
                              maxLength: 30,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'Write your category, e.g. Travel & Tourism',
                                helperText: 'Letters and numbers only, 2 to 30 characters.',
                                counterText: '',
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          const FormLabel('Price', requiredField: true),
                          const SizedBox(height: 8),
                          PriceInput(controller: _priceController, enabled: !_saving),
                          const SizedBox(height: 22),
                          const FormLabel('Tech stack (comma separated)'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _techController,
                            enabled: !_saving,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(hintText: 'Flutter, Firebase'),
                          ),
                          const SizedBox(height: 28),
                          const ProjectImagesHeading(),
                          const SizedBox(height: 12),
                          PickedImagesGrid(
                            images: _images,
                            enabled: !_saving,
                            onAdd: _pickImages,
                            onRemove: (i) => setState(() => _images.removeAt(i)),
                          ),
                          const SizedBox(height: 28),
                          VerificationLinks(demoController: _demoLinkController, githubController: _githubLinkController),
                          const SizedBox(height: 28),
                          if (_saving) ...[
                            const LinearProgressIndicator(minHeight: 3),
                            const SizedBox(height: 8),
                            Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            const SizedBox(height: 14),
                          ],
                          SubmitButton(submitted: _submitted, onPressed: _saving ? () {} : _submit),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}