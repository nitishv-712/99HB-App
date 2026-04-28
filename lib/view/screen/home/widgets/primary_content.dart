import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/model/property.dart';

class DetailPrimaryContent extends StatelessWidget {
  final ApiProperty property;
  const DetailPrimaryContent({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                property.title,
                style: GoogleFonts.notoSerif(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${property.saves}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'saves',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                property.locationString.isNotEmpty
                    ? property.locationString
                    : [
                        property.address.street,
                        property.address.city,
                        property.address.state,
                      ].whereType<String>().join(', '),
                style: GoogleFonts.inter(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          property.priceLabel.isNotEmpty
              ? property.priceLabel
              : '₹ ${property.price.toStringAsFixed(0)}',
          style: GoogleFonts.notoSerif(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            DetailStatItem(
              icon: Icons.bed_outlined,
              label: 'Bedrooms',
              value: '${property.bedrooms}',
            ),
            if (property.bathrooms != null)
              DetailStatItem(
                icon: Icons.bathtub_outlined,
                label: 'Bathrooms',
                value: '${property.bathrooms}',
              ),
            DetailStatItem(
              icon: Icons.square_foot_outlined,
              label: 'Built Area',
              value: '${property.sqft.toStringAsFixed(0)} sqft',
            ),
            if (property.yearBuilt != null)
              DetailStatItem(
                icon: Icons.calendar_today_outlined,
                label: 'Year Built',
                value: '${property.yearBuilt}',
              ),
          ],
        ),
        const SizedBox(height: 32),
        DetailSectionHeader('About This Property'),
        const SizedBox(height: 12),
        Text(
          property.description ?? 'No description available.',
          style: GoogleFonts.inter(
            color: cs.onSurfaceVariant,
            fontSize: 15,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 28),
        DetailInfoCard(
          icon: Icons.map_outlined,
          title: 'Location Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  property.address.street,
                  property.address.city,
                  property.address.state,
                  property.address.zip,
                ].whereType<String>().join(', '),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                ),
              ),
              if (property.address.country.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  property.address.country,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class DetailStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const DetailStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 148,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: cs.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailSectionHeader extends StatelessWidget {
  final String title;
  const DetailSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.notoSerif(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Divider(color: cs.outlineVariant.withValues(alpha: 0.2)),
        ),
      ],
    );
  }
}

class DetailInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const DetailInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: cs.onSurface.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
