import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color bg;
  final Color? iconColor;
  final Color? titleColor;
  final Color? descColor;

  const ServiceTile({super.key, 
    required this.icon,
    required this.title,
    required this.desc,
    required this.bg,
    this.iconColor,
    this.titleColor,
    this.descColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? cs.onSurface, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor ?? cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12,
              color: descColor ?? cs.onSurfaceVariant,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
