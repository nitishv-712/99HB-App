import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/providers/misc_providers.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String? propertyId;
  const PropertyDetailScreen({super.key, this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _navIndex = 1;
  bool _isFavorite = false;
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 72)),
                SliverToBoxAdapter(child: _HeroGallery(isFavorite: _isFavorite, onFavorite: () => setState(() => _isFavorite = !_isFavorite))),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16),
                    child: isWide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 8, child: _PrimaryContent()),
                            const SizedBox(width: 48),
                            SizedBox(width: 360, child: _Sidebar(messageCtrl: _messageCtrl)),
                          ])
                        : Column(children: [
                            _PrimaryContent(),
                            const SizedBox(height: 24),
                            _Sidebar(messageCtrl: _messageCtrl),
                          ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            _TopNav(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex),
    );
  }
}

// ── Top Nav ───────────────────────────────────────────────────────────────────

class _TopNav extends StatelessWidget {
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
                  backgroundColor: AppColors.surfaceContainerHighest,
                  backgroundImage: const NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC2bZ8wQ-jgmtxrO3cAs49nkLIJ09NPCwFrnsezCC7vOhmZ7gItMHTVmwToznkWHWhlHGVRNh55XldVzOzT6Ul0bqgKCe9Nj-Rb26L3j2EUu9gEdFlPXauPJLmB-z9Ta9o9a5ykDaLbegEhnJ10wfmqCmFLuqr6pzErWm--LPMPBYB_p2KBSwntKJgL4VhJzr3a3VkQn1mcxH9v8NnmadLwQgFezXwQ5jcYS9CCnYKgKg5BqPw_o1r9ZJcBnvHriShcjzjA7f8V',
                  ),
                ),
                const SizedBox(width: 12),
                Text('The Curated Estate',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: cs.onSurface, letterSpacing: -0.5,
                  )),
              ]),
              Icon(Icons.search, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hero Gallery ──────────────────────────────────────────────────────────────

class _HeroGallery extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavorite;
  const _HeroGallery({required this.isFavorite, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAnMLhI2B71KsGfPpjVuOXawCaiU33ACKibBwysbNOvtCh36gBqNyQ61GhC87L-aErqu87eS7Lb9XCGwmJkl8scBZq82sFx9cT6i9OkXqCAV0Z1WgbV8Fb4fjsu44Nt6nKggnFb-DyP-3-wwJIbmyuU_SX2Qr6PsCuNk8JOOfXz1Faa2iBINcmYp-M7ZFV7sWkYbwQ3wx1yRnJI4PlsyVl1onutWAXwhIK-HYA-ml-czaRcuctsZPYKYIObPVOyDyNlCeuekYRW',
                fit: BoxFit.cover,
              ),
              // Badges
              Positioned(
                top: 20, left: 20,
                child: Row(children: [
                  _Badge('FOR SALE', cs.primary, cs.onPrimary),
                  const SizedBox(width: 8),
                  _Badge('PREMIUM', AppColors.tertiaryContainer, AppColors.onTertiaryContainer),
                ]),
              ),
              // Favorite
              Positioned(
                top: 16, right: 16,
                child: GestureDetector(
                  onTap: onFavorite,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: Colors.white, size: 22,
                    ),
                  ),
                ),
              ),
              // Dots
              Positioned(
                bottom: 16, left: 0, right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _Dot(active: true),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                ]),
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: fg, letterSpacing: 1.5)),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8, height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.white : Colors.white.withOpacity(0.4),
      ),
    );
  }
}

// ── Primary Content ───────────────────────────────────────────────────────────

class _PrimaryContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Title + Rating
      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Text('The Obsidian Heights Pavilion',
            style: GoogleFonts.notoSerif(fontSize: 32, fontWeight: FontWeight.w900, color: cs.onSurface, height: 1.2)),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 4),
            Text('4.9', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
      ]),
      const SizedBox(height: 12),

      // Location
      Row(children: [
        Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
        const SizedBox(width: 4),
        Text('Jubilee Hills, Hyderabad, Telangana',
          style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Text('View Map',
          style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline, decorationColor: AppColors.primary.withOpacity(0.3))),
      ]),
      const SizedBox(height: 16),

      // Price
      Text('₹ 42.50 Cr',
        style: GoogleFonts.notoSerif(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
      const SizedBox(height: 24),

      // Stats row
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          _StatItem(icon: Icons.bed_outlined, label: 'Bedrooms', value: '06', first: true),
          _StatItem(icon: Icons.bathtub_outlined, label: 'Bathrooms', value: '08'),
          _StatItem(icon: Icons.square_foot_outlined, label: 'Built Area', value: '12,400 sqft'),
          _StatItem(icon: Icons.calendar_today_outlined, label: 'Year Built', value: '2023'),
        ]),
      ),
      const SizedBox(height: 32),

      // 3D Walkthrough
      GestureDetector(
        onTap: () {},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 180, width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuA8ZGIfeBux6-5DM6mCsuEP_zBGs1Jh7fLMM3pQFFiWC_EdRws-r2oP9KWBz_Y79AONy2FnDM0EIxTGtFIJngM3bK_YacInFgYHSX_Xasmje9uP7nI82iRV0GAp-ibJVVI_DPmcwTRxeQ-RE2v2xV5ovAvCubDc-iNOY5BTAazKpzrvYioc7-qKkq9sLaHPnUJV2qkrhHXwNLeaWp2oLivdUMdxbnLXxJh0PXL_dTfYh1YsTYwtaqHxmbeDbtq5bqGXmFrzkMKw',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.6),
                colorBlendMode: BlendMode.darken,
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.threesixty_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                Text("Experience '99ehome' 3D Walkthrough",
                  style: GoogleFonts.notoSerif(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('LAUNCH IMMERSIVE STUDIO',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white60, letterSpacing: 2)),
              ]),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 36),

      // About
      _SectionHeader('About This Property'),
      const SizedBox(height: 12),
      Text(
        'Nestled atop the most prestigious ridge in Jubilee Hills, The Obsidian Heights Pavilion represents a pinnacle of contemporary architectural mastery. Designed by world-renowned artisans, this estate seamlessly blends monolithic concrete forms with warm teakwood accents. The triple-height foyer leads to expansive living areas that bleed into an infinity pool overlooking the city skyline.',
        style: GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 15, height: 1.7),
      ),
      const SizedBox(height: 28),

      // RERA + Location cards
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _InfoCard(
          icon: Icons.verified_outlined,
          title: 'RERA Verification',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Registration No:', style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('P02400002154',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(999)),
              child: Text('AUTHENTICATED PROPERTY',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold,
                  color: const Color(0xFF15803D), letterSpacing: 1)),
            ),
          ]),
        )),
        const SizedBox(width: 16),
        Expanded(child: _InfoCard(
          icon: Icons.map_outlined,
          title: 'Location Details',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Plot 112, Road No. 45, Jubilee Hills, Hyderabad',
              style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Distance to airport: 35 mins',
              style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant.withOpacity(0.6))),
          ]),
        )),
      ]),
      const SizedBox(height: 16),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool first;
  const _StatItem({required this.icon, required this.label, required this.value, this.first = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: first ? 0 : 12),
        decoration: first ? null : BoxDecoration(
          border: Border(left: BorderSide(color: cs.outlineVariant.withOpacity(0.3))),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold,
              letterSpacing: 1.5, color: cs.onSurfaceVariant.withOpacity(0.6))),
          const SizedBox(height: 6),
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold))),
          ]),
        ]),
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
    return Row(children: [
      Text(title, style: GoogleFonts.notoSerif(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(width: 16),
      Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.2))),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15))),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final TextEditingController messageCtrl;
  const _Sidebar({required this.messageCtrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      // Owner + Inquiry card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Listed By',
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold,
              letterSpacing: 2, color: cs.onSurfaceVariant.withOpacity(0.6))),
          const SizedBox(height: 16),
          Row(children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: const NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCvTi-fqV11kQ_m7pcwt0LwJZtf2FDeUb1kkRyLWt7sgDcBJ6fG_1zYOAyU8-9izZe1KmjlwoVY5QqdD_gpPI9csHMXdJS05DUuMAV51ubVgs0eZdZ71TpN8mgIWqTEO5mmfQTRA0xc5id4ARpsLnVhb09_6rTLrnfuiyCQ3CFzVq8zGCJpPpeOyGLtJHE-QhloStGGakfInERsULY9EzEGhdWml8Aflfgjv1Ggk4ts1hRML3amiOOqgKomxDm5T4PCBjHFwCvC',
              ),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rajiv Malhotra',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Certified Luxury Partner',
                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
            ]),
          ]),
          const SizedBox(height: 20),

          // Message field
          Text('Message',
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold,
              letterSpacing: 2, color: cs.onSurfaceVariant.withOpacity(0.6))),
          const SizedBox(height: 8),
          TextField(
            controller: messageCtrl,
            maxLines: 4,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'I am interested in this property and would like to schedule a private viewing...',
              hintStyle: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                onPressed: () => AppRouter.push(context, AppRoutes.signIn),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                label: Text('SEND INQUIRY',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, fontSize: 13)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Call / Email / Share
          Divider(color: cs.outlineVariant.withOpacity(0.15)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _ContactAction(icon: Icons.call_outlined, label: 'Call'),
            Container(width: 1, height: 32, color: cs.outlineVariant.withOpacity(0.2)),
            _ContactAction(icon: Icons.mail_outline_rounded, label: 'Email'),
            Container(width: 1, height: 32, color: cs.outlineVariant.withOpacity(0.2)),
            _ContactAction(icon: Icons.share_outlined, label: 'Share'),
          ]),
        ]),
      ),
      const SizedBox(height: 20),

      // Financing card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Financing Options',
            style: GoogleFonts.notoSerif(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Exclusive mortgage rates starting at 8.25% for curated estates.',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.8), height: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: const StadiumBorder(),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              onPressed: () {},
              child: Text('Calculate EMI',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold,
                  color: Colors.white, letterSpacing: 2)),
            ),
          ),
        ]),
      ),
    ]);
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
      child: Column(children: [
        Icon(icon, color: cs.onSurfaceVariant, size: 22),
        const SizedBox(height: 4),
        Text(label,
          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold,
            letterSpacing: 1.5, color: cs.onSurfaceVariant.withOpacity(0.6))),
      ]),
    );
  }
}

