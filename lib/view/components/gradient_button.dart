import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

/// Full-width gradient CTA button used across all screens.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double fontSize;
  final double letterSpacing;
  final double borderRadius;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.fontSize = 13,
    this.letterSpacing = 2,
    this.borderRadius = 999,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.gradientCta,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: icon != null
            ? ElevatedButton.icon(
                style: _style(borderRadius),
                onPressed: onPressed,
                icon: icon!,
                label: _label(),
              )
            : ElevatedButton(
                style: _style(borderRadius),
                onPressed: onPressed,
                child: _label(),
              ),
      ),
    );
  }

  ButtonStyle _style(double radius) => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      );

  Widget _label() => Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: letterSpacing,
          fontSize: fontSize,
        ),
      );
}
