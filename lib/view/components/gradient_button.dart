import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double fontSize;
  final double letterSpacing;
  final double borderRadius;
  final Widget? icon;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.fontSize = 13,
    this.letterSpacing = 2,
    this.borderRadius = 999,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? (gradient ?? AppColors.gradientCta)
              : null,
          color: onPressed == null ? cs.surfaceContainerHigh : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: icon != null
            ? ElevatedButton.icon(
                style: _style(cs),
                onPressed: onPressed,
                icon: icon!,
                label: _label(cs),
              )
            : ElevatedButton(
                style: _style(cs),
                onPressed: onPressed,
                child: _label(cs),
              ),
      ),
    );
  }

  ButtonStyle _style(ColorScheme cs) => ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );

  Widget _label(ColorScheme cs) => Text(
    label,
    style: GoogleFonts.inter(
      fontWeight: FontWeight.bold,
      color: onPressed != null ? Colors.white : cs.onSurface.withOpacity(0.4),
      letterSpacing: letterSpacing,
      fontSize: fontSize,
    ),
  );
}
