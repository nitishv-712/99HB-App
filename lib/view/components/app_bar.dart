import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '99',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            TextSpan(
              text: 'HB',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: cs.onSurfaceVariant,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: cs.onSurface,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
