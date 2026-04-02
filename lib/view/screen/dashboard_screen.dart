import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/gradient_button.dart';
import 'package:homebazaar/view/components/property_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 2;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 768;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
                SliverToBoxAdapter(child: _ProfileHeader(onNewListing: () {})),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                const SliverToBoxAdapter(child: _CommandCenter()),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverToBoxAdapter(
                  child: _TabSection(
                    tabIndex: _tabIndex,
                    onTabChanged: (i) => setState(() => _tabIndex = i),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            const _TopBar(),
            // FAB
            Positioned(
              bottom: 100, right: isWide ? 32 : 24,
              child: _GradientFab(onTap: () {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

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
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAdTO6IXNviWVQw6E7pCbMpoMZykfFZze-RVzmclr197pbk9RaljPdaaXUK0NqmT8l_MjtzIRr2bMsfaEGXiu84wbqVw9T-0Rp6h7FWexU0hDarLPnzRU0GFEHk5YLKpY63bHQZUh7xVIl4i4p7cnaCVG2qOqL69wE6VTukLsllMONOPPS8iTVOfokhZCi2HOgNI0jSVvqkikoHXZXLMXBR3KxKxSsOhYZUbspXbozoYSbWRv02bFWPY3NdltE6Hbx_FpqVfoRZ',
                  ),
                ),
                const SizedBox(width: 12),
                Text('The Curated Estate',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: cs.onSurface, letterSpacing: -0.5,
                  )),
              ]),
              Row(children: [
                Icon(Icons.search, color: AppColors.primary),
                const SizedBox(width: 16),
                Icon(Icons.notifications_outlined, color: cs.onSurface.withOpacity(0.6)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onNewListing;
  const _ProfileHeader({required this.onNewListing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(width: 6),
                Text('Agent / Seller',
                  style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.bold,
                    letterSpacing: 2, color: AppColors.tertiary,
                  )),
              ]),
            ),
            const SizedBox(height: 10),
            Text('Vikram Malhotra',
              style: GoogleFonts.notoSerif(
                fontSize: 28, fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('vikram.m@curatedestate.in',
              style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
          ]),
          SizedBox(
            width: 130,
            child: GradientButton(
              label: 'NEW LISTING',
              onPressed: onNewListing,
              padding: const EdgeInsets.symmetric(vertical: 12),
              fontSize: 12,
              letterSpacing: 1.5,
              borderRadius: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Command Center ────────────────────────────────────────────────────────────

class _CommandCenter extends StatelessWidget {
  const _CommandCenter();

  static const _items = [
    (Icons.analytics_outlined, 'Analytics'),
    (Icons.compare_arrows_outlined, 'Comparisons'),
    (Icons.star_outline_rounded, 'My Reviews'),
    (Icons.chat_bubble_outline_rounded, 'Inquiries'),
    (Icons.history_rounded, 'Search History'),
    (Icons.support_agent_outlined, 'Support'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Command Center',
            style: GoogleFonts.notoSerif(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: cs.outlineVariant.withOpacity(0.3))),
        ]),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _items.length,
          itemBuilder: (_, i) => _CommandTile(icon: _items[i].$1, label: _items[i].$2),
        ),
      ]),
    );
  }
}

class _CommandTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CommandTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            Text(label,
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.bold, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

// ── Tab Section ───────────────────────────────────────────────────────────────

class _TabSection extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  const _TabSection({required this.tabIndex, required this.onTabChanged});

  static const _tabs = [
    (Icons.favorite_rounded, Icons.favorite_border_rounded, 'SAVED'),
    (Icons.list_alt_rounded, Icons.list_alt_outlined, 'MY LISTINGS'),
  ];

  static const _saved = [
    PropertyItem(
      title: 'The Azure Pavilion',
      location: 'South Goa',
      price: '₹8.4 Cr',
      bhk: '4 Beds',
      sqft: '4,200 sq.ft',
      badge: 'No Brokerage',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAj2wmNcocohv6fX6QAJ1ecVbtk1uGMtKtsUTFi6K3RFxN6U1eitjn8UxlpnXlFYGI-6zI_wslrAa6mQhqxOp9ldSwpHHwbn5YCyXHjcUlFwl-8XFerkYD6nCl0XVMrbpq1jYU1QSDwd7QQxgEsdfrSOFmq_DkhOpS6Npa5YZuced1wSZ9vww2aaW0L-buLCcn_I-oKgOAJzCZQl-f1KcwLmD-EQhLZchJlR-QC7av-6-WhWLo5zNe7h1CWzz_YrZciKGX-6Te0',
    ),
    PropertyItem(
      title: 'Skyline Residence 402',
      location: 'Worli, Mumbai',
      price: '₹12.2 Cr',
      bhk: '3 Suites',
      sqft: 'Level 42',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAIUDk2SSApGHo-_V_mIX0j1VHWJaS8sdKhixDQhbk3Qp15YZJG-ICCExrL0jMAArP61NOFnTpIY7Lc6etxmYah8la7MTGialB9IqCK1DOzgZwBH1K2YGvA4XQRA3Jgt3_uuELe13hyaoJgnopdPVX6VT7Aq5F9baYK-uZ90VgzO6K2UaX5EUv0XmA6ZgEDE-VgOGKtj7FtyPl1Tm8wuTouG4U8en50LMn8XodRKdWUB_EzjWNuU5NyFMU8Hv5cC1hy1WVRpEsf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Tab bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final active = i == tabIndex;
              return GestureDetector(
                onTap: () => onTabChanged(i),
                child: Container(
                  margin: const EdgeInsets.only(right: 28),
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? cs.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(children: [
                    Icon(
                      active ? _tabs[i].$1 : _tabs[i].$2,
                      size: 16,
                      color: active ? cs.primary : cs.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(_tabs[i].$3,
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.bold,
                        color: active ? cs.primary : cs.onSurface.withOpacity(0.4),
                      )),
                  ]),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 32,
            crossAxisSpacing: 16,
            childAspectRatio: 0.58,
          ),
          itemCount: _saved.length,
          itemBuilder: (_, i) => _SavedCard(item: _saved[i], staggered: i.isOdd),
        ),
      ]),
    );
  }
}

// ── Saved Card ────────────────────────────────────────────────────────────────

class _SavedCard extends StatefulWidget {
  final PropertyItem item;
  final bool staggered;
  const _SavedCard({required this.item, required this.staggered});

  @override
  State<_SavedCard> createState() => _SavedCardState();
}

class _SavedCardState extends State<_SavedCard> {
  bool _saved = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(top: widget.staggered ? 40 : 0),
      child: GestureDetector(
        onTap: () => AppRouter.push(context, AppRoutes.propertyDetail, args: widget.item.title),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(widget.item.imageUrl, fit: BoxFit.cover),
                // Favorite button
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _saved = !_saved),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: AppColors.primary, size: 18,
                      ),
                    ),
                  ),
                ),
                if (widget.item.badge.isNotEmpty)
                  Positioned(top: 12, left: 12, child: AppBadge(label: widget.item.badge)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.item.location,
            style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.bold,
              letterSpacing: 2.5, color: cs.primary,
            )),
          const SizedBox(height: 4),
          Text(widget.item.title,
            style: GoogleFonts.notoSerif(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.bed_outlined, size: 13, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(widget.item.bhk,
              style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
            const SizedBox(width: 12),
            Icon(Icons.square_foot_outlined, size: 13, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(widget.item.sqft,
              style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant)),
          ]),
          const SizedBox(height: 8),
          Text(widget.item.price,
            style: GoogleFonts.notoSerif(
              fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
        ]),
      ),
    );
  }
}

// ── Gradient FAB ──────────────────────────────────────────────────────────────

class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.gradientCta,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
