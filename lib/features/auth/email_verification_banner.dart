import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proven/features/auth/auth_service.dart';

// Shown on the home screen while the user's email is not verified.
// "Resend" sends a new link, "I verified" checks the status again.
class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({
    super.key,
    required this.authService,
    required this.onVerified,
  });

  final AuthService authService;
  final VoidCallback onVerified; // called when the email is now verified

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  static const _amber = Color(0xFFF5B942);

  bool _busy = false;

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      await widget.authService.resendVerificationEmail();
      if (!mounted) return;
      _show('Verification email sent. Check your inbox and spam.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _show(
        e.code == 'too-many-requests'
            ? 'Too many requests. Please wait a few minutes and try again.'
            : 'Could not send the email. Please try again.',
      );
    } catch (_) {
      if (!mounted) return;
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _check() async {
    setState(() => _busy = true);
    try {
      final verified = await widget.authService.refreshEmailVerified();
      if (!mounted) return;
      if (verified) {
        _show('Email verified. Thank you!');
        widget.onVerified();
      } else {
        _show('Not verified yet. Open the link in the email first.');
      }
    } catch (_) {
      if (!mounted) return;
      _show('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.14),
        border: Border(
          bottom: BorderSide(color: _amber.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.mark_email_unread_outlined, color: _amber, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Please verify your email. We sent you a link.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: _amber),
              ),
            )
          else ...[
            TextButton(
              onPressed: _resend,
              child: const Text('Resend'),
            ),
            TextButton(
              onPressed: _check,
              child: const Text('I verified'),
            ),
          ],
        ],
      ),
    );
  }
}