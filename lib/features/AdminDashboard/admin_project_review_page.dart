import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, FirebaseFirestore;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proven/core/theme/colors.dart';
import 'package:proven/features/projects/projects_repository.dart';
import 'admin_ui.dart';

class AdminProjectReviewPage extends StatefulWidget {
  const AdminProjectReviewPage({super.key, required this.project});

  final Map<String, dynamic> project;

  @override
  State<AdminProjectReviewPage> createState() => _AdminProjectReviewPageState();
}

class _AdminProjectReviewPageState extends State<AdminProjectReviewPage> {
  final _repo = ProjectsRepository();
  late final Future<Map<String, dynamic>?> _creator = _loadCreator();
  bool _busy = false;
  String? _error;

  Map<String, dynamic> get p => widget.project;
  String s(String k) => (p[k] ?? '').toString().trim();

  Future<Map<String, dynamic>?> _loadCreator() async {
    try {
      final d = await FirebaseFirestore.instance
          .collection('users')
          .doc(s('creatorId'))
          .get();
      return d.data();
    } catch (_) {
      return null;
    }
  }

  Future<void> _run(String status, String doneMessage, {String? reason}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.review(s('id'), status, reason: reason);
      if (mounted) Navigator.pop(context, doneMessage);
    } on FirebaseException catch (e) {
      _fail(e.code == 'permission-denied'
          ? 'Only an admin can review projects.'
          : 'Could not save. Check your internet and try again.');
    } catch (_) {
      _fail('Something went wrong. Please try again.');
    }
  }

  void _fail(String m) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = m;
    });
  }

  Future<void> _askReason({
    required String title,
    required String hint,
    required String confirm,
    required String status,
    required String doneMessage,
  }) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _ReasonDialog(title: title, hint: hint, confirm: confirm),
    );
    if (reason != null) _run(status, doneMessage, reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final status = s('status');
    final price = adminNum(p['price']);
    final images = p['images'] is List ? p['images'] as List : const [];
    final cover = images.isEmpty ? '' : '${images.first}';
    final tech = p['techStack'] is List
        ? (p['techStack'] as List).map((e) => '$e').toList()
        : <String>[];

    return Scaffold(
      backgroundColor: AppColors.tertiary,
      appBar: AppBar(
        title: Text(status == 'approved' ? 'Published project' : 'Review project'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _cover(cover),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AdminChip(
                      status.isEmpty
                          ? 'Pending'
                          : status[0].toUpperCase() + status.substring(1),
                      adminStatusColor(status),
                    ),
                    const SizedBox(width: 8),
                    if (s('category').isNotEmpty)
                      AdminChip(s('category'), AppColors.inversePrimary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(s('title'),
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Submitted ${adminDate(p['createdAt'])}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.onTertiaryContainer)),
                const SizedBox(height: 16),
                _box(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('LISTING PRICE',
                                style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1,
                                    color: AppColors.onTertiaryContainer)),
                            const SizedBox(height: 4),
                            Text(adminMoney(price),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: adminGold)),
                          ],
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 44,
                          color: AppColors.outline.withValues(alpha: 0.3)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Creator gets ${adminMoney(price * 0.9)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.inversePrimary)),
                            const SizedBox(height: 4),
                            const Text('Platform fee 10%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onTertiaryContainer)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _creatorBox(),
                const SizedBox(height: 12),
                _box(
                  title: 'Description',
                  child: Text(
                    s('description').isEmpty ? '—' : s('description'),
                    style: TextStyle(
                        height: 1.55, color: Colors.white.withValues(alpha: 0.88)),
                  ),
                ),
                if (tech.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _box(
                    title: 'Tech stack',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in tech) AdminChip(t, AppColors.inversePrimary)
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _box(
                  title: 'Verification links',
                  child: Column(
                    children: [
                      _LinkRow(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'Live demo',
                          url: s('demoLink')),
                      Divider(
                          height: 20,
                          color: AppColors.outline.withValues(alpha: 0.2)),
                      _LinkRow(
                          icon: Icons.code_rounded,
                          label: 'Source code (GitHub)',
                          url: s('githubLink')),
                    ],
                  ),
                ),
                if (s('rejectionReason').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _box(
                    title: 'Last reason',
                    child: Text(s('rejectionReason'),
                        style: const TextStyle(color: adminRed)),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: adminRed)),
                ],
              ],
            ),
          ),
          _actionBar(status),
        ],
      ),
    );
  }

  Widget _actionBar(String status) {
    if (status != 'pending' && status != 'approved') {
      return const SizedBox.shrink();
    }

    final spinner = const SizedBox(
        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.25)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: status == 'approved'
            ? SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _askReason(
                            title: 'Unpublish project',
                            hint: 'Why is this project being unpublished?',
                            confirm: 'Unpublish',
                            status: 'unpublished',
                            doneMessage: 'Project unpublished',
                          ),
                  icon: _busy ? spinner : const Icon(Icons.visibility_off_outlined),
                  label: const Text('Unpublish'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: adminRed,
                    side: BorderSide(color: adminRed.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _busy
                            ? null
                            : () => _askReason(
                                  title: 'Reject project',
                                  hint: 'Tell the creator what to fix',
                                  confirm: 'Reject',
                                  status: 'rejected',
                                  doneMessage: 'Project rejected',
                                ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: adminRed,
                          side: BorderSide(color: adminRed.withValues(alpha: 0.6)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed:
                            _busy ? null : () => _run('approved', 'Project approved'),
                        icon: _busy
                            ? spinner
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Approve'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _creatorBox() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _creator,
      builder: (context, snap) {
        final u = snap.data ?? const <String, dynamic>{};
        String f(String k) => (u[k] ?? '').toString().trim();

        final name = s('ownerName').isNotEmpty
            ? s('ownerName')
            : '${f('firstName')} ${f('lastName')}'.trim();
        final uni = [f('university'), f('faculty')]
            .where((e) => e.isNotEmpty)
            .join(' • ');

        return _box(
          title: 'Creator',
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiary,
                  border: Border.all(color: adminGold, width: 1.5),
                ),
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.inversePrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Creator' : name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (f('email').isNotEmpty)
                      Text(f('email'),
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.onTertiaryContainer)),
                    if (uni.isNotEmpty)
                      Text(uni,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.onTertiaryContainer)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cover(String url) {
    Widget placeholder() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
            ),
          ),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                size: 40, color: AppColors.inversePrimary),
          ),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: url.startsWith('http')
            ? Image.network(url,
                fit: BoxFit.cover, errorBuilder: (_, __, ___) => placeholder())
            : placeholder(),
      ),
    );
  }

  Widget _box({required Widget child, String? title}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: adminCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title,
                  style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.url});
  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final has = url.isNotEmpty;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.inversePrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.onTertiaryContainer)),
              const SizedBox(height: 2),
              Text(has ? url : 'Not provided',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      color: has
                          ? Colors.white
                          : AppColors.onTertiaryContainer.withValues(alpha: 0.8))),
            ],
          ),
        ),
        if (has)
          IconButton(
            tooltip: 'Copy link',
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: AppColors.inversePrimary,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Link copied')));
            },
          ),
      ],
    );
  }
}

/// Asks for a required reason (at least 5 characters).
class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.hint,
    required this.confirm,
  });
  final String title;
  final String hint;
  final String confirm;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _c.text.trim();
    if (t.length < 5) {
      setState(() => _error = 'Please write a reason (at least 5 characters).');
      return;
    }
    Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.tertiaryContainer,
      title: Text(widget.title),
      content: TextField(
        controller: _c,
        maxLines: 3,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint, errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(widget.confirm, style: const TextStyle(color: adminRed)),
        ),
      ],
    );
  }
}