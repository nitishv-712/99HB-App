import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/components/app_bar.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/services/newsletter_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: BrandAppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(),
          const SizedBox(height: 32),
          _QuickActions(),
          const SizedBox(height: 32),
          _FeaturedListings(),
          const SizedBox(height: 32),
          _MarketCarousel(),
          const SizedBox(height: 32),
          _Services(),
          const SizedBox(height: 32),
          _Newsletter(emailCtrl: _emailCtrl),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 380,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: cs.surfaceContainerHigh),
              ),
              // gradient
              DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xE0000000)],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
              // content
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your\nperfect home.',
                      style: GoogleFonts.notoSerif(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Thousands of verified listings across India.',
                      style: TextStyle(
                        color: cs.surface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _HeroBtn(
                            label: 'Buy',
                            icon: Icons.real_estate_agent_outlined,
                            filled: true,
                            onTap: () => AppRouter.push(context, AppRoutes.buy),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HeroBtn(
                            label: 'Rent',
                            icon: Icons.key_outlined,
                            filled: false,
                            onTap: () =>
                                AppRouter.push(context, AppRoutes.rent),
                          ),
                        ),
                      ],
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

class _HeroBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;
  const _HeroBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? cs.surface : cs.surface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: cs.surface.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? cs.onSurface : cs.surface),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: filled ? cs.onSurface : cs.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (
        icon: Icons.real_estate_agent_outlined,
        label: 'Buy',
        onTap: () => AppRouter.push(context, AppRoutes.buy),
      ),
      (
        icon: Icons.key_outlined,
        label: 'Rent',
        onTap: () => AppRouter.push(context, AppRoutes.rent),
      ),
      (
        icon: Icons.compare_arrows_outlined,
        label: 'Compare',
        onTap: () => AppRouter.push(context, AppRoutes.comparisons),
      ),
      (
        icon: Icons.add_home_outlined,
        label: 'List',
        onTap: () => AppRouter.push(context, AppRoutes.createListing),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items
            .map(
              (e) => Expanded(
                child: GestureDetector(
                  onTap: e.onTap,
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(e.icon, size: 22, color: cs.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Market Carousel ─────────────────────────────────────────────────────────────

class _MarketCarousel extends StatefulWidget {
  @override
  State<_MarketCarousel> createState() => _MarketCarouselState();
}

class _MarketCarouselState extends State<_MarketCarousel> {
  final _ctrl = PageController(viewportFraction: 0.88);
  int _page = 0;

  static const _slides = [
    (
      title: 'Mumbai prices up 12%',
      sub: 'Western suburbs see highest demand in Q1 2025.',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF1A1A2E),
    ),
    (
      title: 'New: Verified Listings',
      sub: 'Every property now comes with a legal check badge.',
      icon: Icons.verified_outlined,
      color: Color(0xFF16213E),
    ),
    (
      title: 'Home Loans at 8.4%',
      sub: 'Compare rates from 12+ banks in one place.',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF0F3460),
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final s = _slides[i];
              return AnimatedScale(
                scale: _page == i ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.title,
                              style: GoogleFonts.notoSerif(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: cs.surface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.sub,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.surface.withValues(alpha: 0.6),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(s.icon, color: cs.surface, size: 24),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _page == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _page == i
                    ? cs.onSurface
                    : cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Featured Listings ─────────────────────────────────────────────────────────

class _FeaturedListings extends StatelessWidget {
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Top Listings',
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => AppRouter.push(context, AppRoutes.buy),
                child: Text(
                  'See all',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (provider.featuredLoading)
          const SkeletonFeaturedListings()
        else if (provider.featuredError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: cs.error, size: 18),
                  const SizedBox(width: 10),
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
              height: 100,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
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
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.featured.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = provider.featured[i];
                return _FeaturedCard(
                  imageUrl: p.primaryImageUrl ?? '',
                  title: p.title,
                  location: p.locationString,
                  price: p.priceLabel,
                  badge: p.badge != null ? p.tag : '',
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

class _FeaturedCard extends StatelessWidget {
  final String imageUrl, title, location, price, badge;
  final VoidCallback onTap;
  const _FeaturedCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Container(color: cs.surfaceContainerHigh),
                          )
                        : Container(color: cs.surfaceContainerHigh),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              cs.scrim.withValues(alpha: 0.5),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (badge.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Text(
                        price,
                        style: GoogleFonts.notoSerif(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 11,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// ── Services ──────────────────────────────────────────────────────────────────

class _Services extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (
        icon: Icons.verified_user_outlined,
        title: 'Certified Agents',
        desc: 'Vetted advisors with 10+ years of expertise.',
        dark: false,
      ),
      (
        icon: Icons.view_in_ar_outlined,
        title: '3D Walkthroughs',
        desc: 'Immersive virtual tours of every listing.',
        dark: true,
      ),
      (
        icon: Icons.gavel_outlined,
        title: 'Legal Help',
        desc: 'End-to-end documentation support.',
        dark: false,
      ),
      (
        icon: Icons.groups_outlined,
        title: 'Bulk Buying',
        desc: 'Institutional-grade pricing for investors.',
        dark: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What We Offer',
            style: GoogleFonts.notoSerif(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: items
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: e.dark
                          ? cs.onSurface
                          : cs.surfaceContainerHighest.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          e.icon,
                          size: 26,
                          color: e.dark ? cs.surface : cs.onSurface,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          e.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: e.dark ? cs.surface : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          e.desc,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: e.dark
                                ? cs.surface.withValues(alpha: 0.55)
                                : cs.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Newsletter ────────────────────────────────────────────────────────────────

class _Newsletter extends StatelessWidget {
  final TextEditingController emailCtrl;
  const _Newsletter({required this.emailCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
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
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: cs.surface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Curated listings & market insights, weekly.',
              style: TextStyle(
                color: cs.surface.withValues(alpha: 0.55),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: cs.surface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Your email address',
                      hintStyle: TextStyle(
                        color: cs.surface.withValues(alpha: 0.35),
                      ),
                      filled: true,
                      fillColor: cs.surface.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
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
                      horizontal: 18,
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
