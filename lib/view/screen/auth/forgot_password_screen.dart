import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/error_handler.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
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
  bool _showToast = false;
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
        _ => 'Very Strong',
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
    if (!ok && mounted) {
      final error = context.read<AuthProvider>().error;
      AppErrorHandler.showError(
          context, error ?? 'Failed to send OTP. Please try again.');
    }
  }

  Future<void> _submitChange() async {
    final identity = _identityCtrl.text.trim();
    final otp = _otpCtrls.map((c) => c.text).join();
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
      setState(() => _showToast = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showToast = false);
      });
    } else {
      final error = context.read<AuthProvider>().error;
      AppErrorHandler.showError(
          context, error ?? 'Failed to change password. Please try again.');
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
                                horizontal: 28, vertical: 40),
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.maybePop(context),
                                      child: Row(
                                        children: [
                                          Icon(Icons.arrow_back,
                                              size: 18,
                                              color: cs.onSurfaceVariant),
                                          const SizedBox(width: 6),
                                          Text('Back to Sign In',
                                              style: TextStyle(
                                                  color: cs.onSurfaceVariant,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    Text(
                                      'Reset Password',
                                      style: GoogleFonts.notoSerif(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Enter your email or phone to receive a one-time code.',
                                      style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 40),

                                    AppInputField(
                                      label: 'EMAIL OR PHONE',
                                      controller: _identityCtrl,
                                      hint: 'curator@estate.com',
                                      icon: Icons.alternate_email_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 20),

                                    AppPrimaryButton(
                                        text: 'GET OTP',
                                        onPressed: _requestOtp),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 28),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Divider(
                                                  color: cs.outlineVariant)),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Text(
                                              'ENTER CODE',
                                              style: TextStyle(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              child: Divider(
                                                  color: cs.outlineVariant)),
                                        ],
                                      ),
                                    ),

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
                                    const SizedBox(height: 28),

                                    AppInputField(
                                      label: 'NEW PASSWORD',
                                      controller: _newPassCtrl,
                                      hint: 'Password',
                                      icon: Icons.lock_outline_rounded,
                                      obscure: _obscure,
                                      onChanged: (_) => setState(() {}),
                                      suffix: IconButton(
                                        onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    AppPasswordStrengthBar(
                                      strength: _strength,
                                      label: _strengthLabel,
                                    ),
                                    const SizedBox(height: 28),

                                    AppPrimaryButton(
                                        text: 'CHANGE PASSWORD',
                                        onPressed: _submitChange),
                                  ],
                                ),
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
          if (_loadingOtp || _loadingChange) const AppLoader(),

          if (_showToast)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.onSurface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF4ADE80), size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Password updated successfully',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
      width: 44,
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
        decoration: InputDecoration(
          hintText: '·',
          hintStyle: GoogleFonts.inter(
            fontSize: 20,
            color: cs.onSurfaceVariant.withOpacity(0.4),
          ),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.onSurface, width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
