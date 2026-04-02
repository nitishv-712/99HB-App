import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: cs.surface,
      body: isWide ? _WideLayout(state: this) : _NarrowLayout(state: this),
    );
  }
}

// ── Narrow (mobile) layout ────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final _SignInScreenState state;
  const _NarrowLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        _HeroImage(height: 353),
        _FormCard(state: state, isWide: false),
      ]),
    );
  }
}

// ── Wide (tablet/web) layout ──────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final _SignInScreenState state;
  const _WideLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _FormCard(state: state, isWide: true)),
      Expanded(child: _HeroImage(height: double.infinity)),
    ]);
  }
}

// ── Hero Image ────────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final double height;
  const _HeroImage({required this.height});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = height == double.infinity;

    return SizedBox(
      height: isWide ? double.infinity : height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBg5POcrXyQmOswqq7uCuQjPEDLjSLC7u_lY_R5BMZsqt_hSOgT2Krdq0ltqjHHAx4BS2x2M_wwfLAfAN7P56-sDcWEFAz4vK_lbJMS6ChDB2AGzzkR0bhkWjeClXUif6yAQGukWis4cq6meSMuajh_PY8t-5FMKMeE8UWvVRmSPHL06443KbfbodO-FgKl4GvDJ2LhHhFYNL1W-PGBNFV8BP3zjt0YWg1tg-mJ86JKfy8iQO-eQ-Vu1iiWKk8Z4WqLK2fQnGBu',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, cs.onSurface.withOpacity(0.6)],
              ),
            ),
          ),
          Positioned(
            top: 32, left: 32,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('99HomeBazaar',
                style: GoogleFonts.notoSerif(
                  fontSize: isWide ? 40 : 28, fontWeight: FontWeight.bold,
                  color: Colors.white, letterSpacing: -0.5,
                )),
              const SizedBox(height: 6),
              Text('The Curated Estate',
                style: GoogleFonts.inter(
                  fontSize: isWide ? 16 : 12, color: Colors.white.withOpacity(0.9),
                  letterSpacing: 2, fontWeight: FontWeight.w500,
                )),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Form Card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final _SignInScreenState state;
  final bool isWide;
  const _FormCard({required this.state, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: isWide ? null : const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: isWide ? null : [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome Back',
                style: GoogleFonts.notoSerif(
                  fontSize: isWide ? 36 : 28, fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                )),
              const SizedBox(height: 10),
              Text(
                'Access your exclusive portfolio and curated property recommendations.',
                style: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.8), height: 1.5),
              ),
              const SizedBox(height: 36),

              // Email
              _FieldLabel('Email Address'),
              const SizedBox(height: 8),
              _InputField(
                controller: state._emailCtrl,
                hint: 'name@example.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _FieldLabel('Password'),
                GestureDetector(
                  onTap: () => AppRouter.push(context, AppRoutes.forgotPassword),
                  child: Text('Forgot?',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary)),
                ),
              ]),
              const SizedBox(height: 8),
              _InputField(
                controller: state._passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: state._obscure,
                suffix: IconButton(
                  icon: Icon(state._obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: cs.onSurfaceVariant.withOpacity(0.6), size: 20),
                  onPressed: () => state.setState(() => state._obscure = !state._obscure),
                ),
              ),
              const SizedBox(height: 28),

              // Sign In button
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientCta,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                  onPressed: () async {
                      final ok = await context.read<AuthProvider>().login(
                        email: state._emailCtrl.text.trim(),
                        password: state._passwordCtrl.text,
                      );
                      if (ok && context.mounted) {
                        AppRouter.pushAndClearStack(context, AppRoutes.home);
                      }
                    },
                    child: Text('SIGN IN',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, fontSize: 13)),
                  ),
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Row(children: [
                  Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or',
                      style: GoogleFonts.inter(fontSize: 11, letterSpacing: 2,
                        color: cs.onSurfaceVariant.withOpacity(0.5), fontWeight: FontWeight.w500)),
                  ),
                  Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.3))),
                ]),
              ),

              // Google Sign In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
                    backgroundColor: AppColors.surfaceContainerLowest,
                  ),
                  onPressed: () {},
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _GoogleLogo(),
                    const SizedBox(width: 12),
                    Text('SIGN IN WITH GOOGLE',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                        color: cs.onSurface, letterSpacing: 2)),
                  ]),
                ),
              ),

              // Sign Up link
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                      children: [
                        const TextSpan(text: 'No account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => AppRouter.push(context, AppRoutes.signUp),
                            child: Text('Create one free',
                              style: GoogleFonts.inter(fontSize: 13, color: cs.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: cs.primary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer links
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _FooterLink('Privacy Policy'),
                  const SizedBox(width: 24),
                  _FooterLink('Terms of Service'),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscure;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: GoogleFonts.inter(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.4)),
        filled: true,
        fillColor: AppColors.surfaceContainer,
        prefixIcon: Icon(icon, color: cs.onSurfaceVariant.withOpacity(0.6), size: 20),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paths = [
      ('M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z', const Color(0xFF4285F4)),
      ('M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z', const Color(0xFF34A853)),
      ('M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z', const Color(0xFFFBBC05)),
      ('M12 5.38c1.62 0 3.06.56 4.21 1.66l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z', const Color(0xFFEA4335)),
    ];
    final scale = size.width / 24;
    canvas.scale(scale, scale);
    for (final (d, color) in paths) {
      final path = _parseSvgPath(d);
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  Path _parseSvgPath(String d) => Path()..addPath(_svgPathData(d), Offset.zero);

  Path _svgPathData(String d) {
    final path = Path();
    final re = RegExp(r'([MmLlHhVvCcSsQqTtAaZz])|(-?\d+\.?\d*)');
    final tokens = re.allMatches(d).map((m) => m.group(0)!).toList();
    int i = 0;
    double cx = 0, cy = 0;
    while (i < tokens.length) {
      final cmd = tokens[i++];
      switch (cmd) {
        case 'M': cx = double.parse(tokens[i++]); cy = double.parse(tokens[i++]); path.moveTo(cx, cy);
        case 'C':
          final x1 = double.parse(tokens[i++]), y1 = double.parse(tokens[i++]);
          final x2 = double.parse(tokens[i++]), y2 = double.parse(tokens[i++]);
          cx = double.parse(tokens[i++]); cy = double.parse(tokens[i++]);
          path.cubicTo(x1, y1, x2, y2, cx, cy);
        case 'L': cx = double.parse(tokens[i++]); cy = double.parse(tokens[i++]); path.lineTo(cx, cy);
        case 'z': case 'Z': path.close();
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink(this.text);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(text,
        style: GoogleFonts.inter(
          fontSize: 10, letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
        )),
    );
  }
}
