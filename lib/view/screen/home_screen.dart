import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/services/misc_services.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_top_bar.dart';
import 'package:homebazaar/view/components/gradient_button.dart';
import 'package:homebazaar/view/components/property_card.dart';
import 'package:homebazaar/view/components/section_label.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _locationCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
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
    _locationCtrl.dispose();
    _projectCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
                SliverToBoxAdapter(child: _HeroSection(locationCtrl: _locationCtrl, projectCtrl: _projectCtrl)),
                const SliverToBoxAdapter(child: _QuickLinks()),
                const SliverToBoxAdapter(child: _FeaturedListings()),
                const SliverToBoxAdapter(child: _ElevatedServices()),
                SliverToBoxAdapter(child: _Newsletter(emailCtrl: _emailCtrl)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          const AppTopBar(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex),
    );
  }
}

// ── Hero Section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final TextEditingController locationCtrl;
  final TextEditingController projectCtrl;
  const _HeroSection({required this.locationCtrl, required this.projectCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 768;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: isWide ? 520 : 480,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAOpeLDpgw304A9SYxpR17fTz_Sj1_STQwV7ul52h7Q434lUi5psrYOxARTb4uSL2qALoiqLE5QR5Y1D5T5HEEbsc3P0onGfH52A1yjcvTqIQOx-UheSgPqZ3MAl9f_AZ26S5l0QlMajnyVt1T1czmbrroUEM9FF_x9yPSyFc9UFQZppc_u1dOqDcMq87OCSw8LOGMioilbda6vaMTt0U2tk49YEOaovWvRwOibzifdd0peRqr_F6azuOr3N31o8VnDeRbnMMB5',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, cs.onSurface.withOpacity(0.75)],
                ),
              ),
            ),
            Positioned(
              bottom: 28, left: 24, right: 24,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Find your place\nin the sun.',
                  style: GoogleFonts.notoSerif(
                    fontSize: isWide ? 42 : 36, fontWeight: FontWeight.w900,
                    color: Colors.white, height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16)],
                  ),
                  child: Column(children: [
                    _SearchField(controller: locationCtrl, icon: Icons.location_on_outlined, hint: 'Location'),
                    const SizedBox(height: 8),
                    _SearchField(controller: projectCtrl, icon: Icons.apartment_outlined, hint: 'Project or Builder'),
                    const SizedBox(height: 8),
                    GradientButton(
                      label: 'Search', onPressed: () {},
                      borderRadius: 12,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      letterSpacing: 0.5,
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  const _SearchField({required this.controller, required this.icon, required this.hint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, color: cs.outline, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint, border: InputBorder.none,
              isDense: true, contentPadding: EdgeInsets.zero,
              hintStyle: GoogleFonts.inter(color: cs.outline.withOpacity(0.6), fontSize: 14),
            ),
            style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
          ),
        ),
      ]),
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
      (AppColors.primaryFixed, cs.primary, Icons.real_estate_agent_outlined, 'Buy', AppRoutes.buy),
      (cs.secondaryContainer, cs.secondary, Icons.key_outlined, 'Rent', AppRoutes.buy),
      (AppColors.tertiaryFixed, cs.tertiary, Icons.sell_outlined, 'Sell', AppRoutes.buy),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Row(
        children: items.map((e) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => AppRouter.push(context, e.$5),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(backgroundColor: e.$1, radius: 24,
                    child: Icon(e.$3, color: e.$2, size: 24)),
                  const SizedBox(height: 10),
                  Text(e.$4, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                ]),
              ),
            ),
          ),
        )).toList(),
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

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SectionLabel(eyebrow: 'Curated Selection', headline: 'Featured Listings', headlineFontSize: 22),
          TextButton.icon(
            onPressed: () => AppRouter.push(context, AppRoutes.buy),
            label: Icon(Icons.arrow_forward, color: cs.primary, size: 18),
            icon: Text('View Gallery', style: GoogleFonts.inter(color: cs.primary, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
      if (provider.featuredLoading)
        const SizedBox(height: 340, child: Center(child: CircularProgressIndicator()))
      else if (provider.featuredError != null)
        SizedBox(height: 340, child: Center(child: Text(provider.featuredError!)))
      else
        SizedBox(
          height: 340,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) {
              final p = provider.featured[i];
              return GestureDetector(
                onTap: () => AppRouter.push(context, AppRoutes.propertyDetail, args: p.id),
                child: PropertyCardHorizontal(
                  item: PropertyItem(
                    title: p.title,
                    location: p.locationString,
                    price: p.priceLabel,
                    bhk: '${p.bedrooms} BHK',
                    sqft: '${p.sqft.toInt()} sqft',
                    badge: p.badge != null ? p.tag : '',
                    imageUrl: p.primaryImageUrl ?? '',
                  ),
                ),
              );
            },
          ),
        ),
      const SizedBox(height: 32),
    ]);
  }
}

// ── Elevated Services ─────────────────────────────────────────────────────────

class _ElevatedServices extends StatelessWidget {
  const _ElevatedServices();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Elevated Services', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _ServiceCard(
            bg: AppColors.surfaceContainer, icon: Icons.groups_outlined, iconColor: cs.primary,
            title: 'Bulk Buying Power',
            desc: 'Join exclusive investor groups for institutional-grade pricing on premier assets.',
            height: 180,
          )),
          const SizedBox(width: 12),
          Expanded(child: _ServiceCard(
            bg: cs.primaryContainer, icon: Icons.view_in_ar_outlined, iconColor: Colors.white,
            title: '99ehome 3D', titleColor: Colors.white,
            desc: 'Immersive virtual walkthroughs of every listing.',
            descColor: Colors.white70, height: 180,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ServiceCard(
            bg: AppColors.surfaceContainerLow, icon: Icons.verified_user_outlined, iconColor: cs.tertiary,
            title: 'Certified Agents',
            desc: 'Vetted advisors with 10+ years of local expertise.',
            height: 160,
          )),
          const SizedBox(width: 12),
          Expanded(child: _ServiceCard(
            bg: AppColors.surfaceContainerLowest, icon: Icons.gavel_outlined, iconColor: cs.outline,
            title: 'Legal Help',
            desc: 'End-to-end documentation and compliance support.',
            height: 160,
          )),
        ]),
      ]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String desc;
  final Color? descColor;
  final double height;

  const _ServiceCard({
    required this.bg, required this.icon, required this.iconColor,
    required this.title, this.titleColor,
    required this.desc, this.descColor,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 32),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 15, color: titleColor ?? cs.onSurface)),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.inter(fontSize: 11, color: descColor ?? cs.onSurfaceVariant)),
          ]),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(32)),
        child: Column(children: [
          Text('The Estate Brief',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: cs.surface)),
          const SizedBox(height: 12),
          Text(
            'Curated insights on market trends and exclusive off-market opportunities delivered weekly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: cs.surface.withOpacity(0.6), fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: cs.surface),
            decoration: InputDecoration(
              hintText: 'Your email address',
              hintStyle: GoogleFonts.inter(color: cs.surface.withOpacity(0.3)),
              filled: true, fillColor: cs.surface.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 12),
          GradientButton(
            label: 'Subscribe',
            onPressed: () {
              final email = emailCtrl.text.trim();
              if (email.isNotEmpty) {
                NewsletterService.subscribe(email);
                emailCtrl.clear();
              }
            },
          ),
        ]),
      ),
    );
  }
}
