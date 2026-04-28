import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/error_handler.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/view/components/app_form_fields.dart';
import 'package:homebazaar/view/components/loaders.dart';

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
  int _roleIndex = 0;
  bool _agreed = false;
  bool _obscure = true;
  bool _loading = false;

  int get _strength {
    final p = _passCtrl.text;
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

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) return;
    const roles = [UserRole.buyer, UserRole.seller, UserRole.agent];
    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().register(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: roles[_roleIndex],
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (ok) {
      AppRouter.pushAndClearStack(context, AppRoutes.home);
    } else {
      final error = context.read<AuthProvider>().error;
      AppErrorHandler.showError(
        context,
        error ?? 'Registration failed. Please try again.',
      );
    }
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
                              horizontal: 28,
                              vertical: 40,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            Navigator.maybePop(context),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_back,
                                              size: 18,
                                              color: cs.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Back',
                                              style: TextStyle(
                                                color: cs.onSurfaceVariant,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 28),

                                      Text(
                                        'Create Account',
                                        style: GoogleFonts.notoSerif(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Join the most exclusive real estate network.',
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      _RoleToggle(
                                        selected: _roleIndex,
                                        onChanged: (i) =>
                                            setState(() => _roleIndex = i),
                                      ),
                                      const SizedBox(height: 24),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppInputField(
                                              label: 'FIRST NAME',
                                              controller: _firstCtrl,
                                              hint: 'Arjun',
                                              icon:
                                                  Icons.person_outline_rounded,
                                              validator: (v) =>
                                                  (v == null || v.isEmpty)
                                                  ? 'Required'
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AppInputField(
                                              label: 'LAST NAME',
                                              controller: _lastCtrl,
                                              hint: 'Mehta',
                                              icon:
                                                  Icons.person_outline_rounded,
                                              validator: (v) =>
                                                  (v == null || v.isEmpty)
                                                  ? 'Required'
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      AppInputField(
                                        label: 'EMAIL ADDRESS',
                                        controller: _emailCtrl,
                                        hint: 'your@email.com',
                                        icon: Icons.alternate_email_rounded,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) =>
                                            (v == null ||
                                                v.isEmpty ||
                                                !RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                ).hasMatch(v))
                                            ? 'Enter a valid email'
                                            : null,
                                      ),
                                      const SizedBox(height: 20),

                                      AppInputField(
                                        label: 'PASSWORD',
                                        controller: _passCtrl,
                                        hint: 'Password',
                                        icon: Icons.lock_outline_rounded,
                                        obscure: _obscure,
                                        onChanged: (_) => setState(() {}),
                                        validator: (v) =>
                                            (v == null || v.length < 8)
                                            ? 'Min 8 characters'
                                            : null,
                                        suffix: IconButton(
                                          onPressed: () => setState(
                                            () => _obscure = !_obscure,
                                          ),
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
                                      const SizedBox(height: 20),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                            value: _agreed,
                                            onChanged: (v) => setState(
                                              () => _agreed = v ?? false,
                                            ),
                                            activeColor: cs.onSurface,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            side: BorderSide(
                                              color: cs.outlineVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 12,
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: TextStyle(
                                                    color: cs.onSurfaceVariant,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                  children: [
                                                    const TextSpan(
                                                      text: 'I agree to the ',
                                                    ),
                                                    TextSpan(
                                                      text: 'Terms of Service',
                                                      style: TextStyle(
                                                        color: cs.onSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                      text: ' and ',
                                                    ),
                                                    TextSpan(
                                                      text: 'Privacy Policy',
                                                      style: TextStyle(
                                                        color: cs.onSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 28),

                                      AppPrimaryButton(
                                        text: 'CREATE ACCOUNT',
                                        onPressed: _submit,
                                      ),

                                      const AppOrDivider(),

                                      AppSocialButton(
                                        icon: Icons.g_mobiledata_rounded,
                                        label: 'Continue with Google',
                                        onPressed: () {},
                                      ),

                                      const SizedBox(height: 32),
                                      Center(
                                        child: AppFooterLink(
                                          label: 'Already have an account?',
                                          action: ' Sign in',
                                          onTap: () =>
                                              Navigator.maybePop(context),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading) const AppLoader(),
        ],
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
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
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
                child: Text(
                  roles[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? cs.surface : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
