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
  final int _navIndex = 2;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 72)),
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
            const _DashboardTopBar(),
            // FAB
            Positioned(
              bottom: 100,
              right: isWide ? 32 : 20,
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

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.92),
          border: Border(
            bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.25)),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.gradientCtaVertical,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAdTO6IXNviWVQw6E7pCbMpoMZykfFZze-RVzmclr197pbk9RaljPdaaXUK0NqmT8l_MjtzIRr2bMsfaEGXiu84wbqVw9T-0Rp6h7FWexU0hDarLPnzRU0GFEHk5YLKpY63bHQZUh7xVIl4i4p7cnaCVG2qOqL69wE6VTukLsllMONOPPS8iTVOfokhZCi2HOgNI0jSVvqkikoHXZXLMXBR3KxKxSsOhYZUbspXbozoYSbWRv02bFWPY3NdltE6Hbx_FpqVfoRZ',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              '99',
                              style: GoogleFonts.notoSerif(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '99',
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'HomeBazaar',
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Actions
                Row(
                  children: [
                    _IconBtn(
                      icon: Icons.search_rounded,
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _IconBtn(
                      icon: Icons.notifications_outlined,
                      color: cs.onSurface.withOpacity(0.6),
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Agent / Seller',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.tertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Vikram Malhotra',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'vikram.m@curatedestate.in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: GradientButton(
              label: 'NEW LISTING',
              onPressed: onNewListing,
              padding: const EdgeInsets.symmetric(vertical: 12),
              fontSize: 11,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Command Center',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(width: 12),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemCount: _items.length,
            itemBuilder: (_, i) =>
                _CommandTile(icon: _items[i].$1, label: _items[i].$2),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: cs.onSurface),
            maxLines: 2,
          ),
        ],
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
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAj2wmNcocohv6fX6QAJ1ecVbtk1uGMtKtsUTFi6K3RFxN6U1eitjn8UxlpnXlFYGI-6zI_wslrAa6mQhqxOp9ldSwpHHwbn5YCyXHjcUlFwl-8XFerkYD6nCl0XVMrbpq1jYU1QSDwd7QQxgEsdfrSOFmq_DkhOpS6Npa5YZuced1wSZ9vww2aaW0L-buLCcn_I-oKgOAJzCZQl-f1KcwLmD-EQhLZchJlR-QC7av-6-WhWLo5zNe7h1CWzz_YrZciKGX-6Te0',
    ),
    PropertyItem(
      title: 'Skyline Residence 402',
      location: 'Worli, Mumbai',
      price: '₹12.2 Cr',
      bhk: '3 Suites',
      sqft: 'Level 42',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAIUDk2SSApGHo-_V_mIX0j1VHWJaS8sdKhixDQhbk3Qp15YZJG-ICCExrL0jMAArP61NOFnTpIY7Lc6etxmYah8la7MTGialB9IqCK1DOzgZwBH1K2YGvA4XQRA3Jgt3_uuELe13hyaoJgnopdPVX6VT7Aq5F9baYK-uZ90VgzO6K2UaX5EUv0XmA6ZgEDE-VgOGKtj7FtyPl1Tm8wuTouG4U8en50LMn8XodRKdWUB_EzjWNuU5NyFMU8Hv5cC1hy1WVRpEsf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == tabIndex;
                return GestureDetector(
                  onTap: () => onTabChanged(i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? cs.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          active ? _tabs[i].$1 : _tabs[i].$2,
                          size: 15,
                          color: active
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _tabs[i].$3,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: active
                                    ? cs.primary
                                    : cs.onSurface.withOpacity(0.4),
                                letterSpacing: 0.8,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 32,
              crossAxisSpacing: 14,
              childAspectRatio: 0.58,
            ),
            itemCount: _saved.length,
            itemBuilder: (_, i) =>
                _SavedCard(item: _saved[i], staggered: i.isOdd),
          ),
        ],
      ),
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
        onTap: () => AppRouter.push(
          context,
          AppRoutes.propertyDetail,
          args: widget.item.title,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(widget.item.imageUrl, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _saved = !_saved),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            _saved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    if (widget.item.badge.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: AppBadge(label: widget.item.badge),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.location,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 17),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.bed_outlined, size: 13, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  widget.item.bhk,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.square_foot_outlined,
                  size: 13,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.item.sqft,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.price,
              style: GoogleFonts.notoSerif(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.gradientCtaVertical,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
