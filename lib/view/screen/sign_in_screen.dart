import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/view/components/app_loader.dart';
import 'package:homebazaar/view/components/error_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
                        Expanded(
                          child: Center(
                            child: Transform.translate(
                              offset: const Offset(0, -20),
                              child: _FormCard(state: this),
                            ),
                          ),
                        ),
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
  final _SignInScreenState state;

  const _FormCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      margin: const EdgeInsets.symmetric(vertical: 62),
      decoration: BoxDecoration(color: cs.surface),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: state._formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: GoogleFonts.notoSerif(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Sign in to explore exclusive listings.',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                ),
                const SizedBox(height: 48),

                _InputField(
                  validator: (value) =>
                      (value == null ||
                          value.isEmpty ||
                          !RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value))
                      ? 'Please enter a valid email address'
                      : null,
                  label: 'EMAIL ADDRESS',
                  controller: state._emailCtrl,
                  hint: 'your@email.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                _PasswordField(controller: state._passwordCtrl),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        AppRouter.push(context, AppRoutes.forgotPassword),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _PrimaryButton(
                  text: 'SIGN IN',
                  onPressed: () async {
                    if (!state._formKey.currentState!.validate()) return;
                    state.setState(() => state._loading = true);
                    final ok = await context.read<AuthProvider>().login(
                      email: state._emailCtrl.text.trim(),
                      password: state._passwordCtrl.text,
                    );
                    state.setState(() => state._loading = false);
                    if (ok && context.mounted) {
                      AppRouter.pushAndClearStack(context, AppRoutes.home);
                    } else if (!ok && context.mounted) {
                      final error = context.read<AuthProvider>().error;
                      showErrorDialog(context, error ?? 'Login failed. Please try again.');
                    }
                  },
                ),

                const _OrDivider(),

                _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  onPressed: () {},
                ),

                const SizedBox(height: 40),

                Center(
                  child: _FooterText(
                    label: "Don't have an account?",
                    action: " Create one",
                    onTap: () => AppRouter.push(context, AppRoutes.signUp),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () => AppRouter.replace(context, AppRoutes.home),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ),
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

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _InputField(
      validator: (value) => (value == null || value.isEmpty || value.length < 8)
          ? 'Please enter a valid password (min 8 chars)'
          : null,
      label: 'PASSWORD',
      controller: widget.controller,
      hint: 'Password',
      icon: Icons.lock_outline_rounded,
      obscure: _obscure,
      suffix: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off : Icons.visibility,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Reusable Components ───────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;
  final FormFieldValidator<String> validator;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          validator: validator,
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: cs.onSurfaceVariant),
            suffixIcon: suffix,
            filled: true,
            fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.gradientCta,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: cs.onSurface, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
      child: Row(
        children: [
          Expanded(child: Divider(color: cs.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Divider(color: cs.outlineVariant)),
        ],
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  final String label;
  final String action;
  final VoidCallback onTap;
  const _FooterText({
    required this.label,
    required this.action,
    required this.onTap,
  });

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
            TextSpan(
              text: action,
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
