import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/core/theme/app_theme.dart';
import 'package:homebazaar/model/comparison.dart';
import 'package:homebazaar/model/property.dart';
import 'package:homebazaar/model/user.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/comparisons_provider.dart';
import 'package:homebazaar/providers/inquiries_provider.dart';

class DetailSidebar extends StatelessWidget {
  final ApiProperty property;
  final TextEditingController messageCtrl;
  const DetailSidebar({
    super.key,
    required this.property,
    required this.messageCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final owner = property.owner is ApiUser ? property.owner as ApiUser : null;
    final ownerName = owner != null
        ? '${owner.firstName} ${owner.lastName}'
        : 'Owner';
    final ownerAvatar = owner?.avatar;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: cs.onSurface.withValues(alpha: 0.06),
                blurRadius: 16,
              ),
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
                  color: cs.onSurfaceVariant.withValues(alpha: 0.85),
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
                        owner?.role ?? 'Property Owner',
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
              Text(
                'Message',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'I am interested in this property...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.75),
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
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientCta,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
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
                      messageCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Inquiry sent successfully'
                                : 'Failed to send inquiry',
                          ),
                        ),
                      );
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
              Divider(color: cs.outlineVariant.withValues(alpha: 0.15)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ContactAction(icon: Icons.call_outlined, label: 'Call'),
                  Container(
                    width: 1,
                    height: 32,
                    color: cs.outlineVariant.withValues(alpha: 0.2),
                  ),
                  _ContactAction(
                    icon: Icons.mail_outline_rounded,
                    label: 'Email',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: cs.outlineVariant.withValues(alpha: 0.2),
                  ),
                  _ContactAction(icon: Icons.share_outlined, label: 'Share'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DetailAddToComparisonButton(propertyId: property.id),
        const SizedBox(height: 20),
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
              color: cs.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
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
  Widget build(BuildContext context) => Column(
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

class DetailAddToComparisonButton extends StatelessWidget {
  final String propertyId;
  const DetailAddToComparisonButton({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
          if (prov.comparisons.isNotEmpty) ...[
            Text(
              'EXISTING',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: cs.onSurfaceVariant.withValues(alpha: 0.85),
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
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
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
                            ? const AppLoaderInline(
                                size: 18,
                                strokeWidth: 2,
                                color: Colors.white,
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
          color: cs.surfaceContainerHighest.withValues(
            alpha: added ? 0.5 : 0.3,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: added ? 0.1 : 0.25),
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
              const AppLoaderInline(size: 18, strokeWidth: 2)
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
