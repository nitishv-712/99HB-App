import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/services/misc_services.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_top_bar.dart';
import 'package:homebazaar/view/components/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertiesProvider>().fetchFeatured();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
                SliverToBoxAdapter(
                  child: _HeroSection(searchCtrl: _searchCtrl),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                const SliverToBoxAdapter(child: _QuickLinks()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                const SliverToBoxAdapter(child: _FeaturedListings()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                const SliverToBoxAdapter(child: _ServicesSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverToBoxAdapter(
                  child: _NewsletterSection(emailCtrl: _emailCtrl),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
          const AppTopBar(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

// ── Hero Section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final TextEditingController searchCtrl;
  const _HeroSection({required this.searchCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 420,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: cs.surfaceContainerHigh),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x33000000), Color(0xDD000000)],
                  ),
                ),
              ),
              Positioned(
                bottom: 28,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your\nperfect home.',
                      style: GoogleFonts.notoSerif(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchCtrl,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'City, neighbourhood or project...',
                                hintStyle: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => AppRouter.push(context, AppRoutes.buy),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: cs.onSurface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Search',
                                style: GoogleFonts.inter(
                                  color: cs.surface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick Links ───────────────────────────────────────────────────────────────

class _QuickLinks extends StatelessWidget {
  const _QuickLinks();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (
        icon: Icons.real_estate_agent_outlined,
        label: 'Buy',
        color: cs.onSurface,
      ),
      (icon: Icons.key_outlined, label: 'Rent', color: cs.onSurface),
      (icon: Icons.sell_outlined, label: 'Sell', color: cs.onSurface),
      (icon: Icons.calculate_outlined, label: 'EMI', color: cs.onSurface),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items
            .map(
              (e) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => AppRouter.push(context, AppRoutes.buy),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(e.icon, color: e.color, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          e.label,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Featured Listings ─────────────────────────────────────────────────────────

class _FeaturedListings extends StatelessWidget {
  const _FeaturedListings();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<PropertiesProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEATURED',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top Listings',
                    style: GoogleFonts.notoSerif(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => AppRouter.push(context, AppRoutes.buy),
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: cs.onSurface),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (provider.featuredLoading)
          const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (provider.featuredError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: cs.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.featuredError!,
                      style: TextStyle(
                        color: cs.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (provider.featured.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No listings available',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final p = provider.featured[i];
                return PropertyCardHorizontal(
                  item: PropertyItem(
                    title: p.title,
                    location: p.locationString,
                    price: p.priceLabel,
                    bhk: '${p.bedrooms} BHK',
                    sqft: '${p.sqft.toInt()} sqft',
                    badge: p.badge != null ? p.tag : '',
                    imageUrl: p.primaryImageUrl ?? '',
                  ),
                  onTap: () => AppRouter.push(
                    context,
                    AppRoutes.propertyDetail,
                    args: p.id,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Services Section ──────────────────────────────────────────────────────────

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SERVICES',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What We Offer',
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ServiceTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Certified Agents',
                  desc: 'Vetted advisors with 10+ years of expertise.',
                  bg: cs.surfaceContainerHighest.withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ServiceTile(
                  icon: Icons.view_in_ar_outlined,
                  title: '3D Walkthroughs',
                  desc: 'Immersive virtual tours of every listing.',
                  bg: cs.onSurface,
                  iconColor: cs.surface,
                  titleColor: cs.surface,
                  descColor: cs.surface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ServiceTile(
                  icon: Icons.gavel_outlined,
                  title: 'Legal Help',
                  desc: 'End-to-end documentation support.',
                  bg: cs.surfaceContainerHighest.withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ServiceTile(
                  icon: Icons.groups_outlined,
                  title: 'Bulk Buying',
                  desc: 'Institutional-grade pricing for investors.',
                  bg: cs.surfaceContainerHighest.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color bg;
  final Color? iconColor;
  final Color? titleColor;
  final Color? descColor;

  const _ServiceTile({
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
      padding: const EdgeInsets.all(18),
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

// ── Newsletter Section ────────────────────────────────────────────────────────

class _NewsletterSection extends StatelessWidget {
  final TextEditingController emailCtrl;
  const _NewsletterSection({required this.emailCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cs.onSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stay in the loop',
              style: GoogleFonts.notoSerif(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: cs.surface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get curated market insights and exclusive listings delivered weekly.',
              style: TextStyle(
                color: cs.surface.withOpacity(0.6),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: cs.surface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Your email address',
                      hintStyle: TextStyle(color: cs.surface.withOpacity(0.35)),
                      filled: true,
                      fillColor: cs.surface.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    final email = emailCtrl.text.trim();
                    if (email.isNotEmpty) {
                      NewsletterService.subscribe(email);
                      emailCtrl.clear();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Join',
                      style: GoogleFonts.inter(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
