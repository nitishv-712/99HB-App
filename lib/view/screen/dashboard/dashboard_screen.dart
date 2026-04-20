import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/providers/analytics_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:homebazaar/view/components/app_top_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchSaved();
      context.read<UserProvider>().fetchMyListings();
      context.read<InquiriesProvider>().fetchMyInquiries();
      context.read<AnalyticsProvider>().fetchOverview();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: NestedScrollView(
                  headerSliverBuilder: (_, __) => [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 60),
                          _ProfileCard(user: user),
                          const SizedBox(height: 20),
                          _StatsRow(),
                          const SizedBox(height: 20),
                          _QuickActions(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        TabBar(
                          controller: _tabCtrl,
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          unselectedLabelStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          labelColor: cs.onSurface,
                          unselectedLabelColor: cs.onSurfaceVariant,
                          indicatorColor: cs.onSurface,
                          indicatorWeight: 2,
                          indicatorSize: TabBarIndicatorSize.label,
                          dividerColor: cs.outlineVariant.withOpacity(0.3),
                          tabs: const [
                            Tab(text: 'SAVED'),
                            Tab(text: 'MY LISTINGS'),
                          ],
                        ),
                        cs.surface,
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabCtrl,
                    children: [_SavedTab(), _MyListingsTab()],
                  ),
                ),
              ),
            ),
          ),
          const AppTopBar(),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

// ── Pinned Tab Bar Delegate ───────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color background;
  const _TabBarDelegate(this.tabBar, this.background);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(_, __, ___) => Container(
    color: background,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: tabBar,
  );

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabBar != tabBar;
}

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final ApiUser? user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = user != null
        ? '${user!.firstName} ${user!.lastName}'
        : 'Guest';
    final email = user?.email ?? '';
    final role = user?.role ?? 'buyer';
    final avatar = user?.avatar;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          // Gradient ring avatar
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF9F77DD),
                  Color(0xFF5DCAA5),
                  Color(0xFFF09595),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.surface,
                ),
                child: ClipOval(
                  child: avatar != null
                      ? Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarFallback(name: name, cs: cs),
                        )
                      : _AvatarFallback(name: name, cs: cs),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.notoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user?.isVerified == true) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded, size: 16, color: cs.primary),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Edit profile button
          _AnimatedIconButton(icon: Icons.edit_outlined, onTap: () {}, cs: cs),
        ],
      ),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _AnimatedIconButton({
    required this.icon,
    required this.onTap,
    required this.cs,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.cs.outlineVariant.withOpacity(0.3),
            ),
          ),
          child: Icon(widget.icon, size: 16, color: widget.cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  final ColorScheme cs;
  const _AvatarFallback({required this.name, required this.cs});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase();
    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final saved = context.watch<UserProvider>().saved.length;
    final listings = context.watch<UserProvider>().myListings.length;
    final inquiries = context.watch<InquiriesProvider>().inquiries.length;

    final stats = [
      (
        label: 'Saved',
        value: '$saved',
        icon: Icons.favorite_border_rounded,
        trend: '+3',
        positive: true,
      ),
      (
        label: 'Listings',
        value: '$listings',
        icon: Icons.home_work_outlined,
        trend: 'active',
        positive: true,
      ),
      (
        label: 'Inquiries',
        value: '$inquiries',
        icon: Icons.chat_bubble_outline_rounded,
        trend: '5 new',
        positive: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(stats.length, (i) {
          final s = stats[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
              child: _AnimatedStatCard(
                label: s.label,
                value: s.value,
                icon: s.icon,
                trend: s.trend,
                positive: s.positive,
                delay: Duration(milliseconds: 80 * i),
                cs: cs,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final bool positive;
  final Duration delay;
  final ColorScheme cs;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.trend,
    required this.positive,
    required this.delay,
    required this.cs,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final trendColor = widget.positive
        ? const Color(0xFF3B6D11)
        : const Color(0xFFA32D2D);

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(widget.icon, size: 18, color: cs.onSurface),
              const SizedBox(height: 7),
              Text(
                widget.value,
                style: GoogleFonts.notoSerif(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                widget.label,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                widget.trend,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
            ],
          ),
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
    final analytics = context.watch<AnalyticsProvider>().overview;

    final actions = [
      (
        icon: Icons.add_home_outlined,
        label: 'New\nListing',
        onTap: () => AppRouter.push(context, AppRoutes.createListing),
        primary: true,
      ),
      (
        icon: Icons.analytics_outlined,
        label: analytics != null
            ? '${analytics.totalViews}\nViews'
            : 'Analytics',
        onTap: () => AppRouter.push(context, AppRoutes.analytics),
        primary: false,
      ),
      (
        icon: Icons.compare_arrows_outlined,
        label: 'Compare',
        onTap: () => AppRouter.push(context, AppRoutes.comparisons),
        primary: false,
      ),
      (
        icon: Icons.support_agent_outlined,
        label: 'Support',
        onTap: () => AppRouter.push(context, AppRoutes.support),
        primary: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(actions.length, (i) {
              final a = actions[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < actions.length - 1 ? 10 : 0,
                  ),
                  child: _PressableActionCard(
                    icon: a.icon,
                    label: a.label,
                    onTap: a.onTap,
                    isPrimary: a.primary,
                    cs: cs,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PressableActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final ColorScheme cs;

  const _PressableActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.cs,
  });

  @override
  State<_PressableActionCard> createState() => _PressableActionCardState();
}

class _PressableActionCardState extends State<_PressableActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? cs.onSurface
                : cs.surfaceContainerHighest.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary
                  ? cs.onSurface
                  : cs.outlineVariant.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: widget.isPrimary ? cs.surface : cs.onSurface,
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: widget.isPrimary ? cs.surface : cs.onSurface,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Saved Tab ─────────────────────────────────────────────────────────────────

class _SavedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    if (provider.savedLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.savedError != null) {
      return _ErrorState(
        message: provider.savedError!,
        onRetry: () => context.read<UserProvider>().fetchSaved(),
      );
    }
    if (provider.saved.isEmpty) {
      return const _EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No saved properties',
        subtitle: 'Properties you save will appear here.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 28,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: provider.saved.length,
      itemBuilder: (_, i) => _PropertyCard(
        property: provider.saved[i],
        staggered: i.isOdd,
        index: i,
      ),
    );
  }
}

// ── My Listings Tab ───────────────────────────────────────────────────────────

class _MyListingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    if (provider.listingsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.listingsError != null) {
      return _ErrorState(
        message: provider.listingsError!,
        onRetry: () => context.read<UserProvider>().fetchMyListings(),
      );
    }
    if (provider.myListings.isEmpty) {
      return _EmptyState(
        icon: Icons.home_work_outlined,
        title: 'No listings yet',
        subtitle: 'Your published properties will appear here.',
        action: 'Add Listing',
        onAction: () {},
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: provider.myListings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _ListingRow(property: provider.myListings[i], index: i),
    );
  }
}

// ── Property Card (Saved grid) ────────────────────────────────────────────────

class _PropertyCard extends StatefulWidget {
  final ApiProperty property;
  final bool staggered;
  final int index;
  const _PropertyCard({
    required this.property,
    required this.staggered,
    required this.index,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageUrl = widget.property.primaryImageUrl;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.only(top: widget.staggered ? 36 : 0),
          child: GestureDetector(
            onTap: () => AppRouter.push(
              context,
              AppRoutes.propertyDetail,
              args: widget.property.id,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _ImgPlaceholder(cs: cs),
                              )
                            : _ImgPlaceholder(cs: cs),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.45),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Text(
                            widget.property.priceLabel,
                            style: GoogleFonts.notoSerif(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.property.title,
                  style: GoogleFonts.notoSerif(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
                        widget.property.locationString,
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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

// ── Listing Row (My Listings list) ────────────────────────────────────────────

class _ListingRow extends StatefulWidget {
  final ApiProperty property;
  final int index;
  const _ListingRow({required this.property, required this.index});

  @override
  State<_ListingRow> createState() => _ListingRowState();
}

class _ListingRowState extends State<_ListingRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final imageUrl = widget.property.primaryImageUrl;
    final status = widget.property.status.name.toUpperCase();
    final isActive = widget.property.status == PropertyStatus.active;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => AppRouter.push(
            context,
            AppRoutes.propertyDetail,
            args: widget.property.id,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ImgPlaceholder(cs: cs),
                          )
                        : _ImgPlaceholder(cs: cs),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.property.title,
                        style: GoogleFonts.notoSerif(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                              widget.property.locationString,
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            widget.property.priceLabel,
                            style: GoogleFonts.notoSerif(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFEAF3DE)
                                  : cs.surfaceContainerHighest.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF27500A)
                                    : cs.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cs.onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    action!,
                    style: GoogleFonts.inter(
                      color: cs.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: cs.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  final ColorScheme cs;
  const _ImgPlaceholder({required this.cs});

  @override
  Widget build(BuildContext context) => Container(
    color: cs.surfaceContainerHigh,
    child: Icon(Icons.image_outlined, color: cs.outline, size: 28),
  );
}
