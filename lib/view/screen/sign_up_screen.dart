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
  int _roleIndex = 0;
  bool _agreed = false;
  bool _obscure = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  int get _passwordStrength {
    final p = _passCtrl.text;
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
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(child: Center(child: _FormCard(state: this))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_loading) const AppLoader(),
        ],
      ),
    );
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final _SignUpScreenState state;
  const _FormCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: state._formKey,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
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

              // Role toggle
              _RoleToggle(
                selected: state._roleIndex,
                onChanged: (i) => state.setState(() => state._roleIndex = i),
              ),
              const SizedBox(height: 24),

              // Name row
              Row(children: [
                Expanded(child: _InputField(
                  label: 'FIRST NAME', controller: state._firstCtrl, hint: 'Arjun',
                  icon: Icons.person_outline_rounded,
                )),
                const SizedBox(width: 12),
                Expanded(child: _InputField(
                  label: 'LAST NAME', controller: state._lastCtrl, hint: 'Mehta',
                  icon: Icons.person_outline_rounded,
                )),
              ]),
              const SizedBox(height: 20),

              _InputField(
                label: 'EMAIL ADDRESS', controller: state._emailCtrl,
                hint: 'your@email.com', icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _InputField(
                label: 'PASSWORD', controller: state._passCtrl,
                hint: 'Password', icon: Icons.lock_outline_rounded,
                obscure: state._obscure,
                onChanged: (_) => state.setState(() {}),
                suffix: IconButton(
                  onPressed: () => state.setState(() => state._obscure = !state._obscure),
                  icon: Icon(
                    state._obscure ? Icons.visibility_off : Icons.visibility,
                    color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 8),

              // Strength bars
              _StrengthBar(strength: state._passwordStrength, label: state._strengthLabel),
              const SizedBox(height: 20),

              // Terms
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(
                  value: state._agreed,
                  onChanged: (v) => state.setState(() => state._agreed = v ?? false),
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

              // Create Account button
              _PrimaryButton(
                text: 'CREATE ACCOUNT',
                onPressed: () async {
                  if (!state._formKey.currentState!.validate()) return;
                  if (!state._agreed) return;
                  const roles = [UserRole.buyer, UserRole.seller, UserRole.agent];
                  state.setState(() => state._loading = true);
                  final ok = await context.read<AuthProvider>().register(
                    firstName: state._firstCtrl.text.trim(),
                    lastName: state._lastCtrl.text.trim(),
                    email: state._emailCtrl.text.trim(),
                    password: state._passCtrl.text,
                    role: roles[state._roleIndex],
                  );
                  state.setState(() => state._loading = false);
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
    );
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

// ── Strength Bar ──────────────────────────────────────────────────────────────

class _StrengthBar extends StatelessWidget {
  final int strength;
  final String label;
  const _StrengthBar({required this.strength, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (strength) {
      0 => cs.outlineVariant, 1 => cs.error,
      2 => const Color(0xFFF59E0B), 3 => const Color(0xFF22C55E),
      _ => const Color(0xFF16A34A),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(4, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          height: 4,
          decoration: BoxDecoration(
            color: i < strength ? color : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ))),
      const SizedBox(height: 4),
      Text('Strength: $label',
        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
    ]);
  }
}

// ── Shared Components (same as sign_in) ───────────────────────────────────────

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
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: cs.onSurfaceVariant),
          suffixIcon: suffix,
          filled: true,
          fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text,
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
            style: TextStyle(
              color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
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
