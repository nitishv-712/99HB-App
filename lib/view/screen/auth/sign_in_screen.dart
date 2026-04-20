import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/error_handler.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/view/components/app_form_fields.dart';
import 'package:homebazaar/view/components/app_loader.dart';

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

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final ok = await context.read<AuthProvider>().login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    setState(() => _loading = false);
    if (!mounted) return;

    if (ok) {
      AppRouter.pushAndClearStack(context, AppRoutes.home);
    } else {
      final error = context.read<AuthProvider>().error;
      AppErrorHandler.showError(
          context, error ?? 'Login failed. Please try again.');
    }
  }

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
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, -20),
                            child: _FormCard(
                              formKey: _formKey,
                              emailCtrl: _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              onSignIn: _handleSignIn,
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

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onSignIn;

  const _FormCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.onSignIn,
  });

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
            key: formKey,
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

                AppInputField(
                  label: 'EMAIL ADDRESS',
                  controller: emailCtrl,
                  hint: 'your@email.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null ||
                              v.isEmpty ||
                              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v))
                          ? 'Please enter a valid email address'
                          : null,
                ),
                const SizedBox(height: 24),

                _PasswordField(controller: passwordCtrl),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        AppRouter.push(context, AppRoutes.forgotPassword),
                    child: Text('Forgot Password?',
                        style: TextStyle(color: cs.primary)),
                  ),
                ),
                const SizedBox(height: 24),

                AppPrimaryButton(text: 'SIGN IN', onPressed: onSignIn),

                const AppOrDivider(),

                AppSocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  onPressed: () {},
                ),

                const SizedBox(height: 40),

                Center(
                  child: AppFooterLink(
                    label: "Don't have an account?",
                    action: ' Create one',
                    onTap: () => AppRouter.push(context, AppRoutes.signUp),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton(
                    onPressed: () =>
                        AppRouter.replace(context, AppRoutes.home),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Skip',
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 14)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
                            size: 16, color: cs.onSurfaceVariant),
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

// ── Password Field with toggle ────────────────────────────────────────────────

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
    return AppInputField(
      label: 'PASSWORD',
      controller: widget.controller,
      hint: 'Password',
      icon: Icons.lock_outline_rounded,
      obscure: _obscure,
      validator: (v) => (v == null || v.isEmpty || v.length < 8)
          ? 'Please enter a valid password (min 8 chars)'
          : null,
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
