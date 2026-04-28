import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/providers/properties_provider.dart';
import 'package:homebazaar/providers/reviews_provider.dart';
import 'package:homebazaar/providers/saved_provider.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:provider/provider.dart';
import 'widgets/hero_gallery.dart';
import 'widgets/primary_content.dart';
import 'widgets/sidebar.dart';
import 'widgets/reviews_section.dart';

export 'widgets/reviews_section.dart' show ReviewStarRow, SubmitReviewSheet;

class PropertyDetailScreen extends StatefulWidget {
  final String? propertyId;
  const PropertyDetailScreen({super.key, this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
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
              builder: (_, saved, _) {
                final isSaved = saved.isSaved(widget.propertyId!);
                return IconButton(
                  icon: Icon(
                    isSaved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isSaved ? cs.primary : cs.onSurface,
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
          if (prov.detailLoading) return const SkeletonPropertyDetail();
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  if (prov.detail != null) ...[
                  SliverToBoxAdapter(
                    child: DetailHeroGallery(
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
                                  child: DetailPrimaryContent(
                                    property: prov.detail!,
                                  ),
                                ),
                                const SizedBox(width: 48),
                                SizedBox(
                                  width: 360,
                                  child: DetailSidebar(
                                    property: prov.detail!,
                                    messageCtrl: _messageCtrl,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                DetailPrimaryContent(property: prov.detail!),
                                const SizedBox(height: 24),
                                DetailSidebar(
                                  property: prov.detail!,
                                  messageCtrl: _messageCtrl,
                                ),
                                const SizedBox(height: 32),
                                DetailReviewsSection(
                                  propertyId: prov.detail!.id,
                                ),
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
          ],
          );
        },
      ),
    );
  }
}
