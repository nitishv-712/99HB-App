import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'package:homebazaar/view/components/app_form_fields.dart';
import 'package:homebazaar/view/components/loaders.dart';
import 'package:homebazaar/view/components/app_shared.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _panNumberCtrl = TextEditingController();
  final _aadharNumberCtrl = TextEditingController();

  XFile? _avatarFile;
  XFile? _panImageFile;
  XFile? _aadharImageFile;

  String? _avatarUrl;
  String? _panImageUrl;
  String? _aadharImageUrl;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstCtrl.text = user.firstName;
      _lastCtrl.text = user.lastName;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone ?? '';
      _panNumberCtrl.text = (user.panCard?.number ?? '').toUpperCase();
      _aadharNumberCtrl.text = user.aadharCard?.number ?? '';
      _avatarUrl = user.avatar;
      _panImageUrl = user.panCard?.image;
      _aadharImageUrl = user.aadharCard?.image;
    }
    // Auto-uppercase PAN as user types
    _panNumberCtrl.addListener(() {
      final upper = _panNumberCtrl.text.toUpperCase();
      if (_panNumberCtrl.text != upper) {
        _panNumberCtrl.value = _panNumberCtrl.value.copyWith(
          text: upper,
          selection: TextSelection.collapsed(offset: upper.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _panNumberCtrl.dispose();
    _aadharNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(_ImageSlot slot) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      switch (slot) {
        case _ImageSlot.avatar:
          _avatarFile = file;
        case _ImageSlot.pan:
          _panImageFile = file;
        case _ImageSlot.aadhar:
          _aadharImageFile = file;
      }
    });
  }

  Future<void> _save() async {
    final user = await context.read<UserProvider>().updateProfile(
      firstName: _firstCtrl.text.trim().isEmpty ? null : _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim().isEmpty ? null : _lastCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      avatar: _avatarFile?.path ?? _avatarUrl,
      panNumber: _panNumberCtrl.text.trim().isEmpty
          ? null
          : _panNumberCtrl.text.trim(),
      panCardImage: _panImageFile?.path ?? _panImageUrl,
      aadharNumber: _aadharNumberCtrl.text.trim().isEmpty
          ? null
          : _aadharNumberCtrl.text.trim(),
      aadharCardImage: _aadharImageFile?.path ?? _aadharImageUrl,
    );

    if (!mounted) return;
    if (user != null) {
      await context.read<AuthProvider>().fetchMe();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.maybePop(context);
      }
    } else {
      final err = context.read<UserProvider>().updateError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err ?? 'Update failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;
    final updating = context.watch<UserProvider>().updating;

    final fullyLocked = user?.isVerified ?? false;
    final panVerified = fullyLocked || (user?.panCard?.isVerified ?? false);
    final aadharVerified =
        fullyLocked || (user?.aadharCard?.isVerified ?? false);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'Edit Profile',
        actions: [
          if (!fullyLocked)
            TextButton(
              onPressed: updating ? null : _save,
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: updating ? cs.onSurfaceVariant : cs.onSurface,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // ── Locked banner ──────────────────────────────────────────────
              if (fullyLocked) _LockedBanner(cs: cs),

              // ── Avatar header card ──────────────────────────────────────
              _AvatarCard(
                localFile: _avatarFile,
                remoteUrl: _avatarUrl,
                locked: fullyLocked,
                user: user,
                onTap: () => _pick(_ImageSlot.avatar),
              ),
              const SizedBox(height: 24),

              // ── Name / Email / Phone ───────────────────────────────────────
              _Section('PERSONAL INFO'),
              const SizedBox(height: 12),
              if (fullyLocked) ...[
                _ReadOnlyField(
                  label: 'FIRST NAME',
                  value: _firstCtrl.text,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _ReadOnlyField(
                  label: 'LAST NAME',
                  value: _lastCtrl.text,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _ReadOnlyField(
                  label: 'EMAIL ADDRESS',
                  value: _emailCtrl.text,
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 12),
                _ReadOnlyField(
                  label: 'PHONE NUMBER',
                  value: _phoneCtrl.text,
                  icon: Icons.phone_outlined,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: AppInputField(
                        label: 'FIRST NAME',
                        controller: _firstCtrl,
                        hint: 'Arjun',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppInputField(
                        label: 'LAST NAME',
                        controller: _lastCtrl,
                        hint: 'Mehta',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppInputField(
                  label: 'EMAIL ADDRESS',
                  controller: _emailCtrl,
                  hint: 'your@email.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppInputField(
                  label: 'PHONE NUMBER',
                  controller: _phoneCtrl,
                  hint: '+919876543210',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],

              // ── KYC ────────────────────────────────────────────────────────
              const SizedBox(height: 28),
              _Section('KYC DOCUMENTS'),
              const SizedBox(height: 4),
              if (!fullyLocked)
                Text(
                  'Submitting both PAN and Aadhaar will trigger a verification request.',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
              const SizedBox(height: 16),

              // PAN
              _DocSection(
                title: 'PAN CARD',
                icon: Icons.credit_card_outlined,
                numberLabel: 'PAN NUMBER',
                numberCtrl: _panNumberCtrl,
                localFile: _panImageFile,
                remoteUrl: _panImageUrl,
                isVerified: panVerified,
                hint: 'Format: ABCDE1234F',
                onPickImage: () => _pick(_ImageSlot.pan),
              ),
              const SizedBox(height: 16),

              // Aadhaar
              _DocSection(
                title: 'AADHAAR CARD',
                icon: Icons.badge_outlined,
                numberLabel: 'AADHAAR NUMBER',
                numberCtrl: _aadharNumberCtrl,
                localFile: _aadharImageFile,
                remoteUrl: _aadharImageUrl,
                isVerified: aadharVerified,
                hint: '12-digit Aadhaar number',
                keyboardType: TextInputType.number,
                onPickImage: () => _pick(_ImageSlot.aadhar),
              ),

              if (!fullyLocked) ...[
                const SizedBox(height: 32),
                AppPrimaryButton(
                  text: 'SAVE CHANGES',
                  onPressed: updating ? () {} : _save,
                ),
              ],
            ],
          ),
          if (updating) const AppLoader(),
        ],
      ),
    );
  }
}

enum _ImageSlot { avatar, pan, aadhar }

// ── Locked banner ─────────────────────────────────────────────────────────────

class _LockedBanner extends StatelessWidget {
  final ColorScheme cs;
  const _LockedBanner({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFFF59E0B),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your account is fully verified. Profile information is locked and cannot be changed.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar card ───────────────────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final XFile? localFile;
  final String? remoteUrl;
  final bool locked;
  final dynamic user;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.localFile,
    required this.remoteUrl,
    required this.locked,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _ImagePickerTile(
            label: 'PROFILE PICTURE',
            localFile: localFile,
            remoteUrl: remoteUrl,
            isCircle: true,
            locked: locked,
            onTap: onTap,
          ),
          const SizedBox(height: 16),
          Text(
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          if (user?.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user!.email,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Doc section (PAN / Aadhaar) ───────────────────────────────────────────────

class _DocSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String numberLabel;
  final TextEditingController numberCtrl;
  final XFile? localFile;
  final String? remoteUrl;
  final bool isVerified;
  final String hint;
  final TextInputType? keyboardType;
  final VoidCallback onPickImage;

  const _DocSection({
    required this.title,
    required this.icon,
    required this.numberLabel,
    required this.numberCtrl,
    required this.localFile,
    required this.remoteUrl,
    required this.isVerified,
    required this.hint,
    required this.onPickImage,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              _VerificationBadge(verified: isVerified),
            ],
          ),
          const SizedBox(height: 14),

          // Number field
          if (isVerified)
            _ReadOnlyField(
              label: numberLabel,
              value: numberCtrl.text,
              icon: icon,
            )
          else
            AppInputField(
              label: numberLabel,
              controller: numberCtrl,
              hint: hint,
              icon: icon,
              keyboardType: TextInputType.text,
            ),
          const SizedBox(height: 14),

          // Image
          _ImagePickerTile(
            label: 'DOCUMENT IMAGE',
            localFile: localFile,
            remoteUrl: remoteUrl,
            locked: isVerified,
            onTap: onPickImage,
          ),
        ],
      ),
    );
  }
}

// ── Verification badge ────────────────────────────────────────────────────────

class _VerificationBadge extends StatelessWidget {
  final bool verified;
  const _VerificationBadge({required this.verified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFF10B981).withOpacity(0.12)
            : const Color(0xFFF59E0B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: verified
              ? const Color(0xFF34D399).withOpacity(0.3)
              : const Color(0xFFFBBF24).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.check_circle_outline_rounded
                : Icons.access_time_rounded,
            size: 10,
            color: verified ? const Color(0xFF34D399) : const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 4),
          Text(
            verified ? 'VERIFIED' : 'PENDING',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: verified
                  ? const Color(0xFF34D399)
                  : const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Read-only field ───────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: value.isEmpty ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: cs.onSurfaceVariant.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Image picker tile ─────────────────────────────────────────────────────────

class _ImagePickerTile extends StatelessWidget {
  final String label;
  final XFile? localFile;
  final String? remoteUrl;
  final bool isCircle;
  final bool locked;
  final VoidCallback onTap;

  const _ImagePickerTile({
    required this.label,
    required this.localFile,
    required this.remoteUrl,
    required this.locked,
    required this.onTap,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage =
        localFile != null || (remoteUrl != null && remoteUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: locked ? null : onTap,
          child: isCircle
              ? _CircleImage(
                  localFile: localFile,
                  remoteUrl: remoteUrl,
                  locked: locked,
                  cs: cs,
                )
              : _RectImage(
                  localFile: localFile,
                  remoteUrl: remoteUrl,
                  locked: locked,
                  hasImage: hasImage,
                  cs: cs,
                ),
        ),
      ],
    );
  }
}

class _CircleImage extends StatelessWidget {
  final XFile? localFile;
  final String? remoteUrl;
  final bool locked;
  final ColorScheme cs;
  const _CircleImage({
    required this.localFile,
    required this.remoteUrl,
    required this.locked,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surfaceContainerHighest.withOpacity(0.4),
            border: Border.all(
              color: cs.outlineVariant.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: _ImageContent(
              localFile: localFile,
              remoteUrl: remoteUrl,
              cs: cs,
              fallbackIcon: Icons.person_outline_rounded,
            ),
          ),
        ),
        if (!locked)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: cs.onSurface,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Icon(Icons.edit_rounded, size: 13, color: cs.surface),
            ),
          ),
      ],
    );
  }
}

class _RectImage extends StatelessWidget {
  final XFile? localFile;
  final String? remoteUrl;
  final bool locked;
  final bool hasImage;
  final ColorScheme cs;
  const _RectImage({
    required this.localFile,
    required this.remoteUrl,
    required this.locked,
    required this.hasImage,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(locked ? 0.2 : 0.4),
        ),
      ),
      child: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ImageContent(
                    localFile: localFile,
                    remoteUrl: remoteUrl,
                    cs: cs,
                    fallbackIcon: Icons.image_outlined,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            locked
                                ? Icons.lock_outline_rounded
                                : Icons.edit_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locked ? 'LOCKED' : 'CHANGE',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 28,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to upload',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  final XFile? localFile;
  final String? remoteUrl;
  final ColorScheme cs;
  final IconData fallbackIcon;
  const _ImageContent({
    required this.localFile,
    required this.remoteUrl,
    required this.cs,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (localFile != null)
      return Image.file(File(localFile!.path), fit: BoxFit.cover);
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return Image.network(
        remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
      );
    }
    return Icon(fallbackIcon, size: 36, color: cs.onSurfaceVariant);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);
  @override
  Widget build(BuildContext context) => AppSectionLabel(text);
}
