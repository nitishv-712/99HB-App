import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/components/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/analytics_provider.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'widgets/profile_card.dart';
import 'widgets/stats_row.dart';
import 'widgets/quick_actions.dart';
import 'widgets/saved_tab.dart';
import 'widgets/my_listings_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: BrandAppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                DashProfileCard(user: user),
                const SizedBox(height: 20),
                const DashStatsRow(),
                const SizedBox(height: 20),
                const DashQuickActions(),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabCtrl,
                labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                labelColor: cs.onSurface,
                unselectedLabelColor: cs.onSurfaceVariant,
                indicatorColor: cs.onSurface,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: cs.outlineVariant.withOpacity(0.3),
                tabs: const [Tab(text: 'SAVED'), Tab(text: 'MY LISTINGS')],
              ),
              cs.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: const [DashSavedTab(), DashMyListingsTab()],
        ),
      ),
    );
  }
}

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
