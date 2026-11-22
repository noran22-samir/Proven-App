import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proven/features/auth/auth_widgets.dart';

// Step 2 of 3: the user must open the link we emailed before continuing.
// The screen checks by itself every few seconds, and has a manual button too.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.onCheck,
    required this.onResend,
    required this.onVerified,
    required this.onChangeEmail,
  });

  final String email;
  final Future<bool> Function() onCheck; // true when the email is verified
  final Future<void> Function() onResend; // sends a new link
  final VoidCallback onVerified; // go to the next step
  final VoidCallback onChangeEmail; // wrong email: cancel and start again

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  bool _busy = false; // manual check or resend in progress
  bool _checking = false; // any check in progress (also the silent ones)
  int _cooldown = 0; // seconds left before the user can resend again
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _startCooldown(); // a link was just sent
    _pollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _check(silent: true),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown = 30;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  void _showMessage(String text, {required bool isError}) {
    setState(() {
      _message = text;
      _messageIsError = isError;
    });
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    _checking = true;
    if (!silent) setState(() => _busy = true);

    try {
      final verified = await widget.onCheck();
      if (!mounted) return;

      if (verified) {
        _pollTimer?.cancel();
        widget.onVerified();
        return;
      }
      if (!silent) {
        _showMessage(
          'Not verified yet. Open the link in the email first.',
          isError: true,
        );
      }
    } catch (_) {
      if (mounted && !silent) {
        _showMessage('Could not check. Please try again.', isError: true);
      }
    } finally {
      _checking = false;
      if (mounted && !silent) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_busy || _cooldown > 0) return;
    setState(() => _busy = true);

    try {
      await widget.onResend();
      if (!mounted) return;
      _showMessage(
        'A new link was sent. Check your inbox and spam folder.',
        isError: false,
      );
      _startCooldown();
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Could not send the email. Please wait a minute and try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AuthColors.of(context);

    return AuthShell(
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify your email',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: c.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Step 2 of 3 · Confirm your email',
            style: TextStyle(fontSize: 15, color: c.secondaryText),
          ),
          const SizedBox(height: 24),

          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 40,
                color: c.accent,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 15, height: 1.5, color: c.text),
              children: [
                const TextSpan(text: 'We sent a verification link to '),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '. Open it, then come back here. '
                      'This page updates by itself.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Can't find it? Check your spam folder.",
            style: TextStyle(fontSize: 13, color: c.secondaryText),
          ),
          const SizedBox(height: 20),

          if (_message != null) ...[
            AuthBanner(message: _message!, isError: _messageIsError),
            const SizedBox(height: 16),
          ],

          AuthPrimaryButton(
            label: "I've verified my email",
            onPressed: _busy ? null : () => _check(),
            isLoading: _busy,
          ),
          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: (_busy || _cooldown > 0) ? null : _resend,
              child: Text(
                _cooldown > 0 ? 'Resend email in ${_cooldown}s' : 'Resend email',
                style: TextStyle(fontWeight: FontWeight.w600, color: c.accent),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _busy ? null : widget.onChangeEmail,
              child: Text(
                'Wrong email? Use a different one',
                style: TextStyle(color: c.secondaryText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}