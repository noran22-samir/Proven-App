import 'package:flutter/material.dart';
import 'add_project_components.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _titleController = TextEditingController(text: 'ClinicFlow - Healthcare Management Suite');
  final _descriptionController = TextEditingController(text: 'Comprehensive clinic operations suite featuring doctor appointment schedule, real-time patient charts, and pharmacy inventory sync.');
  final _priceController = TextEditingController();
  final _demoLinkController = TextEditingController();
  final _githubLinkController = TextEditingController();
  String _category = 'Healthcare';
  int _imageCount = 2;
  bool _submitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _demoLinkController.dispose();
    _githubLinkController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project submitted for review'), behavior: SnackBarBehavior.floating));
  }

  void _handleImageTap(int index) {
    setState(() {
      if (index < _imageCount) {
        _imageCount = (_imageCount - 1).clamp(0, 4);
      } else if (_imageCount < 4) {
        _imageCount++;
      }
    });
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
                          TextField(controller: _titleController, textInputAction: TextInputAction.next),
                          const SizedBox(height: 22),
                          FormLabel('Description', requiredField: true, counter: '${_descriptionController.text.length} / 1000'),
                          const SizedBox(height: 8),
                          TextField(controller: _descriptionController, maxLines: 4, maxLength: 1000, onChanged: (_) => setState(() {}), buildCounter: (_, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink()),
                          const SizedBox(height: 22),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const FormLabel('Category', requiredField: true), const SizedBox(height: 8), CategoryField(value: _category, onChanged: (value) => setState(() => _category = value ?? _category))])),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const FormLabel('Price', requiredField: true), const SizedBox(height: 8), PriceField(controller: _priceController)])),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const ProjectImagesHeading(),
                          const SizedBox(height: 12),
                          ProjectImageGrid(imageCount: _imageCount, onSlotTap: _handleImageTap),
                          const SizedBox(height: 28),
                          VerificationLinks(demoController: _demoLinkController, githubController: _githubLinkController),
                          const SizedBox(height: 28),
                          SubmitButton(submitted: _submitted, onPressed: _submit),
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
