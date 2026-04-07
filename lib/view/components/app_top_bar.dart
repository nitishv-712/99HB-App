import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  final bool useAssetAvatar;
  final String? networkAvatarUrl;
  final VoidCallback? onSearch;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    this.useAssetAvatar = true,
    this.networkAvatarUrl,
    this.onSearch,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.92),
          border: Border(
            bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.25)),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Brand mark
                _BrandMark(
                  useAsset: useAssetAvatar,
                  networkUrl: networkAvatarUrl,
                ),
                const Spacer(),
                // Trailing widget (search by default)
                trailing ??
                    _IconBtn(
                      icon: Icons.search_rounded,
                      onTap: onSearch ?? () {},
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Brand Mark ────────────────────────────────────────────────────────────────

class _BrandMark extends StatelessWidget {
  final bool useAsset;
  final String? networkUrl;
  const _BrandMark({required this.useAsset, this.networkUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo avatar
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.gradientCtaVertical,
          ),
          child: useAsset
              ? ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _FallbackLogo(),
                  ),
                )
              : networkUrl != null
              ? ClipOval(
                  child: Image.network(
                    networkUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _FallbackLogo(),
                  ),
                )
              : const _FallbackLogo(),
        ),
        const SizedBox(width: 10),
        // Brand text
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '99',
                style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'HomeBazaar',
                style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Fallback logo icon ────────────────────────────────────────────────────────

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '99',
        style: GoogleFonts.notoSerif(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: cs.onSurface, size: 20),
      ),
    );
  }
}
