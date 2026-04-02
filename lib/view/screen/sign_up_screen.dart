import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _roleIndex = 0;
  bool _agreed = false;
  bool _obscure = true;
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

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0: return 'Too short';
      case 1: return 'Weak';
      case 2: return 'Medium';
      case 3: return 'Strong';
      default: return 'Very Strong';
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isWide ? _WideLayout(state: this) : _NarrowLayout(state: this),
    );
  }
}

// ── Layouts ───────────────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  final _SignUpScreenState state;
  const _NarrowLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _TopBar(),
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 80),
            _HeroPanel(isWide: false),
            _FormPanel(state: state, isWide: false),
          ]),
        ),
      ),
    ]);
  }
}

class _WideLayout extends StatelessWidget {
  final _SignUpScreenState state;
  const _WideLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(children: [
        Flexible(flex: 5, child: _HeroPanel(isWide: true)),
        Flexible(
          flex: 7,
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 80),
              _FormPanel(state: state, isWide: true),
            ]),
          ),
        ),
      ]),
      _TopBar(),
    ]);
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.surface.withOpacity(0.85),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7C3200)),
          style: IconButton.styleFrom(
            backgroundColor: Colors.orange.shade50.withOpacity(0.5),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: 12),
        Text('The Curated Estate',
          style: GoogleFonts.notoSerif(
            fontSize: 18, fontWeight: FontWeight.bold,
            color: const Color(0xFF7C2D00), letterSpacing: 2,
          )),
      ]),
    );
  }
}

// ── Hero Panel ────────────────────────────────────────────────────────────────

class _HeroPanel extends StatelessWidget {
  final bool isWide;
  const _HeroPanel({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isWide ? double.infinity : 400,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBs6XiZ3E2GTEDBE9VUXU06lW-SuUMcyZ8i8X7_0wdip5muMAnlcjr1YYiwwbFOWv2JMs5GZt1_Q82-y-jCaZ6ox_IUv7b3RnTf8OsYYXHsWb5zxd4VHRVemjKfXiDaZ83PKpD0_58CKAzsKuStPy4RISqljQZNl8NbJNIUXfrAXTCu6ZM3V8MECHnQ3A15k1scqJiLLRHplaxT1hrqtZD_K_4QkV1oPRtNsqBK8-QsbqkmwcneZRiOcXDFt9I19ZanADM0mrXa',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.2),
            colorBlendMode: BlendMode.darken,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Padding(
              padding: EdgeInsets.all(isWide ? 48 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Begin your journey\nto the perfect address.',
                    style: GoogleFonts.notoSerif(
                      fontSize: isWide ? 40 : 28, fontWeight: FontWeight.bold,
                      color: Colors.white, height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Stat('50K+', 'Properties'),
                      _Stat('10K+', 'Buyers'),
                      _Stat('150+', 'Locations'),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
        style: GoogleFonts.notoSerif(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(label,
        style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, letterSpacing: 2,
          fontWeight: FontWeight.w500)),
    ]);
  }
}

// ── Form Panel ────────────────────────────────────────────────────────────────

class _FormPanel extends StatelessWidget {
  final _SignUpScreenState state;
  final bool isWide;
  const _FormPanel({required this.state, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account',
                style: GoogleFonts.notoSerif(fontSize: 30, fontWeight: FontWeight.bold, color: cs.onSurface)),
              const SizedBox(height: 8),
              Text('Join the most exclusive real estate network in India.',
                style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
              const SizedBox(height: 28),

              // Role toggle
              _RoleToggle(selected: state._roleIndex, onChanged: (i) => state.setState(() => state._roleIndex = i)),
              const SizedBox(height: 24),

              // Name row
              Row(children: [
                Expanded(child: _LabeledField(label: 'First Name', controller: state._firstCtrl, hint: 'Arjun')),
                const SizedBox(width: 16),
                Expanded(child: _LabeledField(label: 'Last Name', controller: state._lastCtrl, hint: 'Mehta')),
              ]),
              const SizedBox(height: 20),

              // Email
              _LabeledField(
                label: 'Email Address',
                controller: state._emailCtrl,
                hint: 'arjun.mehta@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password
              _PasswordField(state: state),
              const SizedBox(height: 20),

              // Terms checkbox
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(
                  value: state._agreed,
                  onChanged: (v) => state.setState(() => state._agreed = v ?? false),
                  activeColor: cs.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: cs.outlineVariant),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant, height: 1.5),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(text: 'Terms of Service',
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500)),
                          const TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy',
                            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500)),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 28),

              // Create Account button
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
                    onPressed: () {},
                    child: Text('CREATE ACCOUNT',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, fontSize: 13)),
                  ),
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(children: [
                  Expanded(child: Divider(color: AppColors.surfaceContainerHighest)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Or join with',
                      style: GoogleFonts.inter(fontSize: 11, letterSpacing: 2,
                        color: cs.onSurfaceVariant.withOpacity(0.6), fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: Divider(color: AppColors.surfaceContainerHighest)),
                ]),
              ),

              // Google button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    side: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
                    backgroundColor: cs.surface,
                  ),
                  onPressed: () {},
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _GoogleLogo(),
                    const SizedBox(width: 12),
                    Text('REGISTER WITH GOOGLE',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold,
                        color: cs.onSurface, letterSpacing: 2)),
                  ]),
                ),
              ),

              // Sign in link
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Text('Sign in',
                              style: GoogleFonts.inter(fontSize: 13, color: cs.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: cs.primary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: List.generate(roles.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? AppColors.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : null,
                ),
                child: Text(roles[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: active ? cs.primary : cs.onSurfaceVariant,
                  )),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Labeled Field ─────────────────────────────────────────────────────────────

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold,
          letterSpacing: 2, color: cs.onSurfaceVariant)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.4)),
          filled: true,
          fillColor: AppColors.surfaceContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    ]);
  }
}

// ── Password Field with strength indicator ────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final _SignUpScreenState state;
  const _PasswordField({required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final strength = state._passwordStrength;

    final strengthColor = switch (strength) {
      0 => cs.outlineVariant,
      1 => cs.error,
      2 => const Color(0xFFF59E0B),
      3 => const Color(0xFF22C55E),
      _ => const Color(0xFF16A34A),
    };

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Password',
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold,
          letterSpacing: 2, color: cs.onSurfaceVariant)),
      const SizedBox(height: 8),
      TextField(
        controller: state._passCtrl,
        obscureText: state._obscure,
        onChanged: (_) => state.setState(() {}),
        style: GoogleFonts.inter(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: '••••••••••••',
          hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withOpacity(0.4)),
          filled: true,
          fillColor: AppColors.surfaceContainer,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(state._obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: cs.onSurfaceVariant.withOpacity(0.6), size: 20),
            onPressed: () => state.setState(() => state._obscure = !state._obscure),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: List.generate(4, (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i < strength ? strengthColor : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        )),
      ),
      const SizedBox(height: 6),
      Text('Strength: ${state._strengthLabel}',
        style: GoogleFonts.inter(fontSize: 10, color: cs.onSurfaceVariant.withOpacity(0.6), letterSpacing: 0.5)),
    ]);
  }
}

// ── Google Logo ───────────────────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 20, height: 20, child: CustomPaint(painter: _GoogleLogoPainter()));
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.scale(scale, scale);
    final segments = [
      ('M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z', const Color(0xFF4285F4)),
      ('M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z', const Color(0xFF34A853)),
      ('M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z', const Color(0xFFFBBC05)),
      ('M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z', const Color(0xFFEA4335)),
    ];
    for (final (d, color) in segments) {
      canvas.drawPath(_parse(d), Paint()..color = color);
    }
  }

  Path _parse(String d) {
    final path = Path();
    final tokens = RegExp(r'([MmLlCcZz])|(-?\d+\.?\d*)').allMatches(d).map((m) => m.group(0)!).toList();
    int i = 0;
    while (i < tokens.length) {
      final cmd = tokens[i++];
      switch (cmd) {
        case 'M': path.moveTo(double.parse(tokens[i++]), double.parse(tokens[i++]));
        case 'C':
          path.cubicTo(double.parse(tokens[i++]), double.parse(tokens[i++]),
            double.parse(tokens[i++]), double.parse(tokens[i++]),
            double.parse(tokens[i++]), double.parse(tokens[i++]));
        case 'L': path.lineTo(double.parse(tokens[i++]), double.parse(tokens[i++]));
        case 'z': case 'Z': path.close();
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
