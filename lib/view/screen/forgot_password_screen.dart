import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

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

  Color get _strengthColor => switch (_strength) {
        0 => AppColors.outlineVariant,
        1 => AppColors.error,
        2 => const Color(0xFFF59E0B),
        3 => AppColors.primary,
        _ => const Color(0xFF16A34A),
      };

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
  }

  void _submitChange() {
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showToast = false);
    });
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
          // Background decoration
          _BackgroundDecor(),

          // Content
          SafeArea(
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          children: [
                            // Header
                            Column(children: [
                              Text('Security',
                                style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  letterSpacing: 3, color: cs.primary,
                                )),
                              const SizedBox(height: 8),
                              Text('RESET PASSWORD',
                                style: GoogleFonts.notoSerif(
                                  fontSize: 30, fontWeight: FontWeight.bold,
                                  color: cs.onSurface, letterSpacing: 1,
                                )),
                              const SizedBox(height: 10),
                              Text(
                                'Enter your credentials to regain access\nto your curated portfolio.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13, color: cs.onSurfaceVariant, height: 1.6),
                              ),
                            ]),
                            const SizedBox(height: 40),

                            // Form card
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step 1 — Identity
                                  _FieldLabel('Email or Phone'),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _identityCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'e.g. curator@estate.com',
                                      hintStyle: GoogleFonts.inter(
                                        color: cs.onSurfaceVariant.withOpacity(0.4), fontSize: 14),
                                      filled: true,
                                      fillColor: AppColors.surfaceContainerLowest,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      suffixIcon: Icon(Icons.verified_user_outlined,
                                        color: cs.primary.withOpacity(0.4), size: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _GradientButton(label: 'GET OTP', onPressed: () {}),

                                  // Divider
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 28),
                                    child: Divider(color: cs.outlineVariant.withOpacity(0.15)),
                                  ),

                                  // Step 2 — OTP
                                  Center(
                                    child: Text('Enter 6-Digit Code',
                                      style: GoogleFonts.inter(
                                        fontSize: 10, fontWeight: FontWeight.bold,
                                        letterSpacing: 2, color: cs.onSurfaceVariant,
                                      )),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (i) => _OtpBox(
                                      controller: _otpCtrls[i],
                                      focusNode: _otpFocus[i],
                                      onChanged: (v) => _onOtpChanged(v, i),
                                    )),
                                  ),
                                  const SizedBox(height: 24),

                                  // New Password
                                  _FieldLabel('New Password'),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _newPassCtrl,
                                    obscureText: _obscure,
                                    onChanged: (_) => setState(() {}),
                                    style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: GoogleFonts.inter(
                                        color: cs.onSurfaceVariant.withOpacity(0.4), fontSize: 14),
                                      filled: true,
                                      fillColor: AppColors.surfaceContainerLowest,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: cs.onSurfaceVariant.withOpacity(0.4), size: 20),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Strength bars
                                  Row(
                                    children: List.generate(4, (i) => Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: i < _strength ? _strengthColor : cs.outlineVariant.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                    )),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Strength: $_strengthLabel',
                                    style: GoogleFonts.inter(
                                      fontSize: 9, fontWeight: FontWeight.w500,
                                      color: _strength > 0 ? _strengthColor : cs.onSurfaceVariant.withOpacity(0.5),
                                    )),
                                  const SizedBox(height: 24),

                                  _GradientButton(label: 'CHANGE PASSWORD', onPressed: _submitChange),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Back to sign in
                            GestureDetector(
                              onTap: () => Navigator.maybePop(context),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.arrow_back, size: 16, color: cs.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text('Return to sign in',
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  )),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Success toast
          if (_showToast)
            Positioned(
              bottom: 40, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inverseSurface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 20),
                    const SizedBox(width: 10),
                    Text('Password updated successfully',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: AppColors.inverseOnSurface,
                      )),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.surface.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(alignment: Alignment.center, children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF7C3200)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange.shade50.withOpacity(0.5),
              shape: const CircleBorder(),
            ),
          ),
        ),
        Text('The Curated Estate',
          style: GoogleFonts.notoSerif(
            fontSize: 17, fontWeight: FontWeight.bold,
            color: const Color(0xFF7C2D00), letterSpacing: 2,
          )),
      ]),
    );
  }
}

// ── OTP Box ───────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

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
        inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: '·',
          hintStyle: GoogleFonts.inter(fontSize: 20, color: cs.onSurfaceVariant.withOpacity(0.4)),
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradientCta,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const StadiumBorder(),
          ),
          onPressed: onPressed,
          child: Text(label,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, fontSize: 13)),
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.bold,
        letterSpacing: 2, color: Theme.of(context).colorScheme.onSurfaceVariant,
      ));
  }
}

// ── Background Decoration ─────────────────────────────────────────────────────

class _BackgroundDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.15,
          child: Stack(children: [
            Positioned(
              top: -80, right: -80,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer.withOpacity(0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -80, left: -80,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryContainer.withOpacity(0.15),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
