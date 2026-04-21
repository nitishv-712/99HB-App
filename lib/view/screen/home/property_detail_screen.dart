import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/review.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/providers/saved_provider.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/providers/reviews_provider.dart';
import 'package:homebazaar/view/components/app_loader.dart';
import 'package:provider/provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String? propertyId;
  const PropertyDetailScreen({super.key, this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final int _navIndex = 1;
  final _messageCtrl = TextEditingController();
  final _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PropertiesProvider>().fetchDetail(widget.propertyId!);
        context.read<ReviewsProvider>().fetchForProperty(widget.propertyId!);
        context.read<SavedProvider>().fetchList();
        context.read<ComparisonsProvider>().fetchList();
      });
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Property Details',
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.propertyId != null)
            Consumer<SavedProvider>(
              builder: (_, saved, __) {
                final isSaved = saved.isSaved(widget.propertyId!);
                return IconButton(
                  icon: Icon(
                    isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isSaved ? AppColors.primary : cs.onSurface,
                  ),
                  onPressed: () =>
                      context.read<SavedProvider>().toggle(widget.propertyId!),
                );
              },
            ),
        ],
      ),
      body: Consumer<PropertiesProvider>(
        builder: (context, prov, _) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  if (prov.detail != null) ...[
                    SliverToBoxAdapter(
                      child: _HeroGallery(
                        property: prov.detail!,
                        pageCtrl: _pageCtrl,
                        currentPage: _currentPage,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 16,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: _PrimaryContent(
                                      property: prov.detail!,
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                  SizedBox(
                                    width: 360,
                                    child: _Sidebar(
                                      property: prov.detail!,
                                      messageCtrl: _messageCtrl,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _PrimaryContent(property: prov.detail!),
                                  const SizedBox(height: 24),
                                  _Sidebar(
                                    property: prov.detail!,
                                    messageCtrl: _messageCtrl,
                                  ),
                                  const SizedBox(height: 32),
                                  _ReviewsSection(propertyId: prov.detail!.id),
                                ],
                              ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                  if (prov.detailError != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: cs.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              prov.detailError!,
                              style: GoogleFonts.inter(
                                color: cs.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () =>
                                  prov.fetchDetail(widget.propertyId!),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (prov.detailLoading) const AppLoader(),
            ],
          );
        },
      ),
    );
  }
}

// ── Hero Gallery ──────────────────────────────────────────────────────────────

class _HeroGallery extends StatelessWidget {
  final ApiProperty property;
  final PageController pageCtrl;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _HeroGallery({
    required this.property,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final images = property.images;
    final hasImages = images.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImages)
                PageView.builder(
                  controller: pageCtrl,
                  onPageChanged: onPageChanged,
                  itemCount: images.length,
                  itemBuilder: (_, i) => Image.network(
                    images[i].url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                )
              else
                Container(
                  color: AppColors.surfaceContainerHighest,
                  child: const Icon(
                    Icons.home_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              // Badges
              Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    _Badge(
                      property.tag.toUpperCase(),
                      cs.primary,
                      cs.onPrimary,
                    ),
                    if (property.badge != null) ...[
                      const SizedBox(width: 8),
                      _Badge(
                        property.badge!.name.toUpperCase(),
                        AppColors.tertiaryContainer,
                        AppColors.onTertiaryContainer,
                      ),
                    ],
                  ],
                ),
              ),
              // Dots
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _Dot(active: i == currentPage),
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

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : Colors.white.withOpacity(0.4),
      ),
    );
  }
}

// ── Primary Content ───────────────────────────────────────────────────────────

class _PrimaryContent extends StatelessWidget {
  final ApiProperty property;
  const _PrimaryContent({required this.property});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Rating
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

        // Location
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
            const SizedBox(width: 8),
            Text(
              'View Map',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price
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

        // Stats grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatItem(
              icon: Icons.bed_outlined,
              label: 'Bedrooms',
              value: '${property.bedrooms}',
            ),
            if (property.bathrooms != null)
              _StatItem(
                icon: Icons.bathtub_outlined,
                label: 'Bathrooms',
                value: '${property.bathrooms}',
              ),
            _StatItem(
              icon: Icons.square_foot_outlined,
              label: 'Built Area',
              value: '${property.sqft.toStringAsFixed(0)} sqft',
            ),
            if (property.yearBuilt != null)
              _StatItem(
                icon: Icons.calendar_today_outlined,
                label: 'Year Built',
                value: '${property.yearBuilt}',
              ),
          ],
        ),
        const SizedBox(height: 32),

        // About
        _SectionHeader('About This Property'),
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

        // Location card
        _InfoCard(
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
                    color: cs.onSurfaceVariant.withOpacity(0.6),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({
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
              color: cs.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

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
        Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.2))),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard({
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
        border: Border.all(color: cs.outlineVariant.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
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

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final ApiProperty property;
  final TextEditingController messageCtrl;
  const _Sidebar({required this.property, required this.messageCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final owner = property.owner is ApiUser ? property.owner as ApiUser : null;
    final ownerName = owner != null
        ? '${owner.firstName} ${owner.lastName}'
        : 'Owner';
    final ownerRole = owner?.role ?? 'Property Owner';
    final ownerAvatar = owner?.avatar;

    return Column(
      children: [
        // Owner + Inquiry card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Listed By',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: cs.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    backgroundImage: ownerAvatar != null
                        ? NetworkImage(ownerAvatar)
                        : null,
                    child: ownerAvatar == null
                        ? Text(
                            ownerName.isNotEmpty
                                ? ownerName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ownerName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ownerRole,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Message field
              Text(
                'Message',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: cs.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText:
                      'I am interested in this property and would like to schedule a private viewing...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),

              // Send Inquiry button
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientCta,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      final auth = context.read<AuthProvider>();
                      if (!auth.isAuthenticated) {
                        AppRouter.push(context, AppRoutes.signIn);
                        return;
                      }
                      final text = messageCtrl.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a message'),
                          ),
                        );
                        return;
                      }
                      final ok = await context.read<InquiriesProvider>().submit(
                        propertyId: property.id,
                        message: text,
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        messageCtrl.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Inquiry sent successfully'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to send inquiry'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'SEND INQUIRY',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Call / Email / Share
              Divider(color: cs.outlineVariant.withOpacity(0.15)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ContactAction(icon: Icons.call_outlined, label: 'Call'),
                  Container(
                    width: 1,
                    height: 32,
                    color: cs.outlineVariant.withOpacity(0.2),
                  ),
                  _ContactAction(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: cs.outlineVariant.withOpacity(0.2),
                  ),
                  _ContactAction(icon: Icons.share_outlined, label: 'Share'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Add to Comparison
        _AddToComparisonButton(propertyId: property.id),

        // Stats card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property Stats',
                style: GoogleFonts.notoSerif(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatChip(
                    icon: Icons.visibility_outlined,
                    label: 'Views',
                    value: '${property.views}',
                  ),
                  _StatChip(
                    icon: Icons.bookmark_border_rounded,
                    label: 'Saves',
                    value: '${property.saves}',
                  ),
                  _StatChip(
                    icon: Icons.question_answer_outlined,
                    label: 'Inquiries',
                    value: '${property.inquiries}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }
}

class _ContactAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: cs.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add to Comparison ─────────────────────────────────────────────────────────

class _AddToComparisonButton extends StatelessWidget {
  final String propertyId;
  const _AddToComparisonButton({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows_outlined, size: 18, color: cs.onSurface),
            const SizedBox(width: 8),
            Text(
              'Add to Comparison',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: context.read<ComparisonsProvider>(),
          ),
        ],
        child: _ComparisonSheet(propertyId: propertyId),
      ),
    );
  }
}

class _ComparisonSheet extends StatefulWidget {
  final String propertyId;
  const _ComparisonSheet({required this.propertyId});

  @override
  State<_ComparisonSheet> createState() => _ComparisonSheetState();
}

class _ComparisonSheetState extends State<_ComparisonSheet> {
  final _nameCtrl = TextEditingController();
  bool _creating = false;
  bool _showCreate = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prov = context.watch<ComparisonsProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add to Comparison',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Existing comparisons
          if (prov.comparisons.isNotEmpty) ...[
            Text(
              'EXISTING',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: cs.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            ...prov.comparisons.map(
              (c) => _ComparisonOption(
                comparison: c,
                propertyId: widget.propertyId,
                onDone: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Create new
          if (!_showCreate)
            GestureDetector(
              onTap: () => setState(() => _showCreate = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '+ New Comparison',
                    style: GoogleFonts.inter(
                      color: cs.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            )
          else ...[
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: 'Comparison name',
                labelStyle: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showCreate = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _creating
                        ? null
                        : () async {
                            final name = _nameCtrl.text.trim();
                            if (name.isEmpty) return;
                            setState(() => _creating = true);
                            await context.read<ComparisonsProvider>().create(
                              name: name,
                              propertyIds: [widget.propertyId],
                            );
                            setState(() => _creating = false);
                            if (context.mounted) Navigator.pop(context);
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: cs.onSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _creating
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.surface,
                                ),
                              )
                            : Text(
                                'Create',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: cs.surface,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ComparisonOption extends StatefulWidget {
  final ApiComparison comparison;
  final String propertyId;
  final VoidCallback onDone;
  const _ComparisonOption({
    required this.comparison,
    required this.propertyId,
    required this.onDone,
  });

  @override
  State<_ComparisonOption> createState() => _ComparisonOptionState();
}

class _ComparisonOptionState extends State<_ComparisonOption> {
  bool _loading = false;

  bool get _alreadyAdded => widget.comparison.propertyIds.any(
    (p) => (p is String ? p : (p as dynamic).id as String) == widget.propertyId,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final added = _alreadyAdded;

    return GestureDetector(
      onTap: added || _loading
          ? null
          : () async {
              setState(() => _loading = true);
              await context.read<ComparisonsProvider>().addProperty(
                widget.comparison.id,
                widget.propertyId,
              );
              setState(() => _loading = false);
              widget.onDone();
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: added
              ? cs.surfaceContainerHighest.withOpacity(0.5)
              : cs.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: added
                ? cs.outlineVariant.withOpacity(0.1)
                : cs.outlineVariant.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.comparison.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: added ? cs.onSurfaceVariant : cs.onSurface,
                    ),
                  ),
                  Text(
                    '${widget.comparison.propertyIds.length} propert${widget.comparison.propertyIds.length == 1 ? 'y' : 'ies'}',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (_loading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onSurface,
                ),
              )
            else if (added)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Colors.green.shade600,
              )
            else
              Icon(Icons.add_rounded, size: 18, color: cs.onSurface),
          ],
        ),
      ),
    );
  }
}

// ── Reviews Section ───────────────────────────────────────────────────────────

class _ReviewsSection extends StatelessWidget {
  final String propertyId;
  const _ReviewsSection({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<ReviewsProvider>(
      builder: (_, prov, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Reviews',
                      style: GoogleFonts.notoSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Divider(color: cs.outlineVariant.withOpacity(0.2)),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showSubmitSheet(context, prov, propertyId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      prov.userReview != null ? 'Edit Review' : 'Write Review',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cs.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats summary
            if (prov.stats != null) _RatingSummary(stats: prov.stats!),

            if (prov.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (prov.reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No reviews yet. Be the first!',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              )
            else
              ...prov.reviews.map((r) => _ReviewCard(review: r)),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showSubmitSheet(
    BuildContext context,
    ReviewsProvider prov,
    String propertyId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: prov,
        child: _SubmitReviewSheet(
          propertyId: propertyId,
          existing: prov.userReview,
        ),
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final ReviewStats stats;
  const _RatingSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Average score
          Column(
            children: [
              Text(
                stats.averageRating.toStringAsFixed(1),
                style: GoogleFonts.notoSerif(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              _StarRow(rating: stats.averageRating.round()),
              const SizedBox(height: 4),
              Text(
                '${stats.totalReviews} reviews',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Breakdown bars
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = _countForStar(star, stats.ratingBreakdown);
                final pct = stats.totalReviews > 0
                    ? count / stats.totalReviews
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.star_rounded, size: 10, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.amber,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  int _countForStar(int star, RatingBreakdown b) {
    switch (star) {
      case 5:
        return b.five;
      case 4:
        return b.four;
      case 3:
        return b.three;
      case 2:
        return b.two;
      default:
        return b.one;
    }
  }
}

class _ReviewCard extends StatelessWidget {
  final ApiReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = review.user is ApiUser ? review.user as ApiUser : null;
    final name = user != null
        ? '${user.firstName} ${user.lastName}'
        : 'Anonymous';
    final avatar = user?.avatar;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                child: avatar == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: cs.onSurface,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      review.createdAt.substring(0, 10),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _StarRow(rating: review.rating),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          size: 14,
          color: Colors.amber,
        ),
      ),
    );
  }
}

// ── Submit Review Sheet ───────────────────────────────────────────────────────

class _SubmitReviewSheet extends StatefulWidget {
  final String propertyId;
  final ApiReview? existing;
  const _SubmitReviewSheet({required this.propertyId, required this.existing});

  @override
  State<_SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends State<_SubmitReviewSheet> {
  late int _rating;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _commentCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 5;
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _commentCtrl = TextEditingController(text: widget.existing?.comment ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEdit ? 'Edit Review' : 'Write a Review',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Star picker
          Text(
            'RATING',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: cs.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 36,
                    color: Colors.amber,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleCtrl,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            maxLines: 4,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              labelText: 'Comment',
              labelStyle: TextStyle(color: cs.onSurfaceVariant),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _loading
                  ? null
                  : () async {
                      if (_titleCtrl.text.trim().isEmpty ||
                          _commentCtrl.text.trim().isEmpty)
                        return;
                      setState(() => _loading = true);
                      bool ok;
                      if (isEdit) {
                        ok = await context.read<ReviewsProvider>().update(
                          widget.existing!.id,
                          rating: _rating,
                          title: _titleCtrl.text.trim(),
                          comment: _commentCtrl.text.trim(),
                        );
                      } else {
                        ok = await context.read<ReviewsProvider>().submit(
                          propertyId: widget.propertyId,
                          rating: _rating,
                          title: _titleCtrl.text.trim(),
                          comment: _commentCtrl.text.trim(),
                        );
                      }
                      setState(() => _loading = false);
                      if (ok && context.mounted) Navigator.pop(context);
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.surface,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Review' : 'Submit Review',
                          style: GoogleFonts.inter(
                            color: cs.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
