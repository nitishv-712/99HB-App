import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/error_handler.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/view/components/app_form_fields.dart';
import 'package:homebazaar/view/components/loaders.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identityCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _obscure = true;
  bool _otpSent = false; // step 1 → step 2
  bool _success = false;
  bool _loadingOtp = false;
  bool _loadingChange = false;

  int get _strength {
    final p = _newPassCtrl.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  String get _strengthLabel => switch (_strength) {
        0 => 'Too short',
        1 => 'Weak',
        2 => 'Medium',
        3 => 'Strong',
        _ => 'Very strong',
      };

  Future<void> _requestOtp() async {
    final identity = _identityCtrl.text.trim();
    if (identity.isEmpty) return;
    final isEmail = identity.contains('@');
    setState(() => _loadingOtp = true);
    final ok = await context.read<AuthProvider>().generateOtp(
          email: isEmail ? identity : null,
          phone: isEmail ? null : identity,
        );
    setState(() => _loadingOtp = false);
    if (!mounted) return;
    if (ok) {
      setState(() => _otpSent = true);
    } else {
      final error = context.read<AuthProvider>().error;
      AppErrorHandler.showError(
        context,
        error ?? 'Failed to send OTP. Please try again.',
      );
    }
  }

  Future<void> _submitChange() async {
    final identity = _identityCtrl.text.trim();
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6 || _newPassCtrl.text.isEmpty) return;
    final isEmail = identity.contains('@');
    setState(() => _loadingChange = true);
    final ok = await context.read<AuthProvider>().changePassword(
          otp: otp,
          newPassword: _newPassCtrl.text,
          email: isEmail ? identity : null,
          phone: isEmail ? null : identity,
        );
    setState(() => _loadingChange = false);
    if (!mounted) return;
    if (ok) {
      setState(() => _success = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.maybePop(context);
    } else {
      final error = context.read<AuthProvider>().error;
      AppErrorHandler.showError(
        context,
        error ?? 'Failed to change password. Please try again.',
      );
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    _identityCtrl.dispose();
    _newPassCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _otpSent
              ? setState(() => _otpSent = false)
              : Navigator.maybePop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface,
            size: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 40,
                            ),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 400),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step indicator
                                  _StepIndicator(step: _otpSent ? 2 : 1),
                                  const SizedBox(height: 28),

                                  // Title
                                  Text(
                                    _otpSent
                                        ? 'Verify & Reset'
                                        : 'Reset Password',
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: cs.onSurface,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _otpSent
                                        ? 'Enter the 6-digit code sent to ${_identityCtrl.text.trim()} and set your new password.'
                                        : 'Enter your email or phone number and we\'ll send you a one-time code.',
                                    style: GoogleFonts.inter(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 36),

                                  // ── Step 1 ──────────────────────────────
                                  if (!_otpSent) ...[
                                    AppInputField(
                                      label: 'EMAIL OR PHONE',
                                      controller: _identityCtrl,
                                      hint: 'you@example.com',
                                      icon: Icons.alternate_email_rounded,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 28),
                                    _ActionButton(
                                      label: 'SEND CODE',
                                      loading: _loadingOtp,
                                      onPressed: _requestOtp,
                                    ),
                                  ],

                                  // ── Step 2 ──────────────────────────────
                                  if (_otpSent) ...[
                                    Text(
                                      'VERIFICATION CODE',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        6,
                                        (i) => _OtpBox(
                                          controller: _otpCtrls[i],
                                          focusNode: _otpFocus[i],
                                          onChanged: (v) =>
                                              _onOtpChanged(v, i),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _loadingOtp
                                            ? null
                                            : _requestOtp,
                                        child: Text(
                                          _loadingOtp
                                              ? 'Sending...'
                                              : 'Resend code',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: cs.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    AppInputField(
                                      label: 'NEW PASSWORD',
                                      controller: _newPassCtrl,
                                      hint: 'Min. 8 characters',
                                      icon: Icons.lock_outline_rounded,
                                      obscure: _obscure,
                                      onChanged: (_) => setState(() {}),
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    AppPasswordStrengthBar(
                                      strength: _strength,
                                      label: _strengthLabel,
                                    ),
                                    const SizedBox(height: 28),
                                    _ActionButton(
                                      label: 'CHANGE PASSWORD',
                                      loading: _loadingChange,
                                      onPressed: _submitChange,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Success overlay
          if (_success)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Password Updated!',
                          style: GoogleFonts.notoSerif(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Redirecting you to sign in...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step; // 1 or 2
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StepDot(number: 1, active: step >= 1, cs: cs),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: step >= 2
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        _StepDot(number: 2, active: step >= 2, cs: cs),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool active;
  final ColorScheme cs;
  const _StepDot(
      {required this.number, required this.active, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? cs.primary : cs.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: cs.onSurface,
          foregroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: loading
            ? AppLoaderInline(size: 20, strokeWidth: 2, color: cs.surface)
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}

// ── OTP Box ───────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
        decoration: InputDecoration(
          hintText: '·',
          hintStyle: GoogleFonts.inter(
            fontSize: 22,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
