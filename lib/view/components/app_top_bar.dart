import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';

/// Frosted-glass top app bar used across all screens.
/// Wrap your screen body in a [Stack] and place this as the last child.
class AppTopBar extends StatelessWidget {
  /// Title shown next to the avatar. Defaults to '99 HomeBazaar'.
  final String title;

  /// Use an asset image for the avatar (e.g. logo). Falls back to network.
  final bool useAssetAvatar;
  final String? networkAvatarUrl;

  /// Called when the search icon is tapped.
  final VoidCallback? onSearch;

  /// Optional trailing widget to replace the search icon.
  final Widget? trailing;

  const AppTopBar({
    super.key,
    this.title = '99 HomeBazaar',
    this.useAssetAvatar = true,
    this.networkAvatarUrl,
    this.onSearch,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        color: cs.surface.withOpacity(0.85),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.primaryContainer,
                  backgroundImage: useAssetAvatar
                      ? const AssetImage('assets/logo.png') as ImageProvider
                      : NetworkImage(networkAvatarUrl ?? ''),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: cs.onSurface, letterSpacing: -0.5,
                  ),
                ),
              ]),
              trailing ?? GestureDetector(
                onTap: onSearch,
                child: Icon(Icons.search, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
