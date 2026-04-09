import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/view/components/app_loader.dart';
import 'package:homebazaar/view/components/error_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _FormCard(
        formKey: _formKey,
        firstCtrl: _firstCtrl,
        lastCtrl: _lastCtrl,
        emailCtrl: _emailCtrl,
        passCtrl: _passCtrl,
      ),
    );
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstCtrl, lastCtrl, emailCtrl, passCtrl;

  const _FormCard({
    required this.formKey, required this.firstCtrl, required this.lastCtrl,
    required this.emailCtrl, required this.passCtrl,
  });

  @override
  State<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<_FormCard> {
  int _roleIndex = 0;
  bool _agreed = false;
  bool _obscure = true;
  bool _loading = false;

  int get _passwordStrength {
    final p = widget.passCtrl.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 8) s++;
    if (p.contains(RegExp(r'[A-Z]'))) s++;
    if (p.contains(RegExp(r'[0-9]'))) s++;
    if (p.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  String get _strengthLabel => switch (_passwordStrength) {
    0 => 'Too short', 1 => 'Weak', 2 => 'Medium',
    3 => 'Strong', _ => 'Very Strong',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Form(
                              key: widget.formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.maybePop(context),
                                    child: Row(children: [
                                      Icon(Icons.arrow_back, size: 18, color: cs.onSurfaceVariant),
                                      const SizedBox(width: 6),
                                      Text('Back', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                                    ]),
                                  ),
                                  const SizedBox(height: 28),

                                  Text('Create Account',
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 32, fontWeight: FontWeight.bold, color: cs.onSurface)),
                                  const SizedBox(height: 12),
                                  Text('Join the most exclusive real estate network.',
                                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                                  const SizedBox(height: 32),

                                  _RoleToggle(
                                    selected: _roleIndex,
                                    onChanged: (i) => setState(() => _roleIndex = i),
                                  ),
                                  const SizedBox(height: 24),

                                  Row(children: [
                                    Expanded(child: _InputField(
                                      label: 'FIRST NAME', controller: widget.firstCtrl,
                                      hint: 'Arjun', icon: Icons.person_outline_rounded,
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(child: _InputField(
                                      label: 'LAST NAME', controller: widget.lastCtrl,
                                      hint: 'Mehta', icon: Icons.person_outline_rounded,
                                    )),
                                  ]),
                                  const SizedBox(height: 20),

                                  _InputField(
                                    label: 'EMAIL ADDRESS', controller: widget.emailCtrl,
                                    hint: 'your@email.com', icon: Icons.alternate_email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 20),

                                  _PasswordField(
                                    controller: widget.passCtrl,
                                    obscure: _obscure,
                                    onToggle: () => setState(() => _obscure = !_obscure),
                                    onChanged: (_) => setState(() {}),
                                    strength: _passwordStrength,
                                    strengthLabel: _strengthLabel,
                                  ),
                                  const SizedBox(height: 20),

                                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Checkbox(
                                      value: _agreed,
                                      onChanged: (v) => setState(() => _agreed = v ?? false),
                                      activeColor: cs.onSurface,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      side: BorderSide(color: cs.outlineVariant),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, height: 1.5),
                                            children: [
                                              const TextSpan(text: 'I agree to the '),
                                              TextSpan(text: 'Terms of Service',
                                                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
                                              const TextSpan(text: ' and '),
                                              TextSpan(text: 'Privacy Policy',
                                                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 28),

                                  _PrimaryButton(
                                    text: 'CREATE ACCOUNT',
                                    onPressed: () async {
                                      if (!widget.formKey.currentState!.validate()) return;
                                      if (!_agreed) return;
                                      const roles = [UserRole.buyer, UserRole.seller, UserRole.agent];
                                      setState(() => _loading = true);
                                      final ok = await context.read<AuthProvider>().register(
                                        firstName: widget.firstCtrl.text.trim(),
                                        lastName: widget.lastCtrl.text.trim(),
                                        email: widget.emailCtrl.text.trim(),
                                        password: widget.passCtrl.text,
                                        role: roles[_roleIndex],
                                      );
                                      setState(() => _loading = false);
                                      if (!context.mounted) return;
                                      if (ok) {
                                        AppRouter.pushAndClearStack(context, AppRoutes.home);
                                      } else {
                                        final error = context.read<AuthProvider>().error;
                                        showErrorDialog(context, error ?? 'Registration failed. Please try again.');
                                      }
                                    },
                                  ),

                                  const _OrDivider(),

                                  _SocialButton(
                                    icon: Icons.g_mobiledata_rounded,
                                    label: 'Continue with Google',
                                    onPressed: () {},
                                  ),

                                  const SizedBox(height: 32),
                                  Center(
                                    child: _FooterText(
                                      label: 'Already have an account?',
                                      action: ' Sign in',
                                      onTap: () => Navigator.maybePop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        if (_loading) const AppLoader(),
      ],
    );
  }
}

// ── Password Field ────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final int strength;
  final String strengthLabel;

  const _PasswordField({
    required this.controller, required this.obscure, required this.onToggle,
    required this.onChanged, required this.strength, required this.strengthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (strength) {
      0 => cs.outlineVariant, 1 => cs.error,
      2 => const Color(0xFFF59E0B), 3 => const Color(0xFF22C55E),
      _ => const Color(0xFF16A34A),
    };

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _InputField(
        label: 'PASSWORD', controller: controller,
        hint: 'Password', icon: Icons.lock_outline_rounded,
        obscure: obscure, onChanged: onChanged,
        suffix: IconButton(
          onPressed: onToggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
            color: cs.onSurfaceVariant)),
      ),
      const SizedBox(height: 8),
      Row(children: List.generate(4, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          height: 4,
          decoration: BoxDecoration(
            color: i < strength ? color : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999)),
        ),
      ))),
      const SizedBox(height: 4),
      Text('Strength: $strengthLabel',
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    ]);
  }
}

// ── Role Toggle ───────────────────────────────────────────────────────────────

class _RoleToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _RoleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const roles = ['BUYER', 'SELLER', 'AGENT'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(roles.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? cs.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(roles[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: active ? cs.surface : cs.onSurfaceVariant)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Shared Components ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.label, required this.hint, required this.icon,
    required this.controller, this.obscure = false, this.suffix,
    this.keyboardType = TextInputType.text, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
        style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.bold,
          letterSpacing: 1.2, color: cs.onSurfaceVariant)),
      const SizedBox(height: 8),
      TextField(
        controller: controller, obscureText: obscure,
        keyboardType: keyboardType, onChanged: onChanged,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: cs.onSurfaceVariant),
          suffixIcon: suffix,
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 1)),
        ),
      ),
    ]);
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.gradientCta,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _SocialButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: cs.onSurface, size: 28),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ]),
    );
  }
}

class _FooterText extends StatelessWidget {
  final String label;
  final String action;
  final VoidCallback onTap;
  const _FooterText({required this.label, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          children: [
            TextSpan(text: label),
            TextSpan(text: action,
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
