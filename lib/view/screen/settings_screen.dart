import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homebazaar/core/router/app_router.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/theme_provider.dart';
import 'package:homebazaar/view/components/app_bottom_nav.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifListings = true;
  bool _notifInquiries = true;
  bool _notifPriceDrops = false;
  bool _notifNewsletter = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.user;

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
          'Settings',
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // ── Profile card ────────────────────────────────────────────────
          if (user != null) ...[
            _ProfileCard(user: user),
            const SizedBox(height: 24),
          ],

          // ── Appearance ──────────────────────────────────────────────────
          _SectionLabel('APPEARANCE'),
          const SizedBox(height: 10),
          _SettingsCard(children: [_ThemeTile(theme: theme)]),
          const SizedBox(height: 24),

          // ── Notifications ───────────────────────────────────────────────
          _SectionLabel('NOTIFICATIONS'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.home_outlined,
                label: 'New Listings',
                subtitle: 'Get notified about new properties',
                value: _notifListings,
                onChanged: (v) => setState(() => _notifListings = v),
              ),
              _Divider(),
              _SwitchTile(
                icon: Icons.question_answer_outlined,
                label: 'Inquiries',
                subtitle: 'Replies to your property inquiries',
                value: _notifInquiries,
                onChanged: (v) => setState(() => _notifInquiries = v),
              ),
              _Divider(),
              _SwitchTile(
                icon: Icons.trending_down_rounded,
                label: 'Price Drops',
                subtitle: 'Alerts when saved properties drop in price',
                value: _notifPriceDrops,
                onChanged: (v) => setState(() => _notifPriceDrops = v),
              ),
              _Divider(),
              _SwitchTile(
                icon: Icons.mail_outline_rounded,
                label: 'Newsletter',
                subtitle: 'Weekly market insights & tips',
                value: _notifNewsletter,
                onChanged: (v) => setState(() => _notifNewsletter = v),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Account ─────────────────────────────────────────────────────
          _SectionLabel('ACCOUNT'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              if (auth.isAuthenticated) ...[
                _NavTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () {},
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Change Password',
                  onTap: () =>
                      AppRouter.push(context, AppRoutes.forgotPassword),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.verified_outlined,
                  label: 'KYC Verification',
                  trailing: user?.isVerified == true
                      ? _StatusBadge('VERIFIED', Colors.green)
                      : _StatusBadge('PENDING', Colors.orange),
                  onTap: () {},
                ),
                _Divider(),
              ],
              _NavTile(
                icon: Icons.language_outlined,
                label: 'Language',
                trailing: Text(
                  'English',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Support ─────────────────────────────────────────────────────
          _SectionLabel('SUPPORT'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _NavTile(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => AppRouter.push(context, AppRoutes.support),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.support_agent_outlined,
                label: 'Contact Support',
                onTap: () => AppRouter.push(context, AppRoutes.support),
              ),
              _Divider(),
              _NavTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {},
              ),
              _Divider(),
              _NavTile(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────────
          _SectionLabel('ABOUT'),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _NavTile(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                trailing: Text(
                  '1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Sign out / Sign in ───────────────────────────────────────────
          if (auth.isAuthenticated)
            _DangerButton(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  AppRouter.pushAndClearStack(context, AppRoutes.signIn);
                }
              },
            )
          else
            _PrimaryButton(
              icon: Icons.login_rounded,
              label: 'Sign In',
              onTap: () => AppRouter.push(context, AppRoutes.signIn),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final dynamic user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = '${user.firstName} ${user.lastName}';
    final avatar = user.avatar as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: cs.surfaceContainerHighest,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.notoSerif(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.notoSerif(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    if (user.isVerified == true) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded, size: 15, color: cs.error),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.email as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
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
                    (user.role as String).toUpperCase(),
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
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
              ),
              child: Icon(Icons.edit_outlined, size: 16, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme Tile ────────────────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  final ThemeProvider theme;
  const _ThemeTile({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              theme.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              size: 18,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose your preferred theme',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ThemeSegment(theme: theme),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  final ThemeProvider theme;
  const _ThemeSegment({required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final options = [
      (icon: Icons.light_mode_outlined, mode: ThemeMode.light),
      (icon: Icons.settings_suggest_outlined, mode: ThemeMode.system),
      (icon: Icons.dark_mode_outlined, mode: ThemeMode.dark),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((o) {
          final selected = theme.themeMode == o.mode;
          return GestureDetector(
            onTap: () => context.read<ThemeProvider>().setMode(o.mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? cs.onSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                o.icon,
                size: 16,
                color: selected ? cs.surface : cs.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: cs.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 0,
      color: cs.outlineVariant.withOpacity(0.15),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: cs.onSurface),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: cs.onSurface,
            activeTrackColor: cs.surfaceContainerHighest,
            inactiveThumbColor: cs.onSurfaceVariant.withOpacity(0.4),
            inactiveTrackColor: cs.surfaceContainerHighest.withOpacity(0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _NavTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: cs.onSurface),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: cs.onSurfaceVariant.withOpacity(0.5),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: color,
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DangerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.error.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: cs.error),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.onSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: cs.surface),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
