import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:homebazaar/providers/auth_provider.dart';
import 'package:homebazaar/providers/user_provider.dart';
import 'package:homebazaar/view/components/app_form_fields.dart';
import 'package:homebazaar/view/components/app_loader.dart';
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
  final _avatarCtrl = TextEditingController();
  final _panNumberCtrl = TextEditingController();
  final _panImageCtrl = TextEditingController();
  final _aadharNumberCtrl = TextEditingController();
  final _aadharImageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _firstCtrl.text = user.firstName;
      _lastCtrl.text = user.lastName;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone ?? '';
      _avatarCtrl.text = user.avatar ?? '';
      _panNumberCtrl.text = user.panCard?.number ?? '';
      _panImageCtrl.text = user.panCard?.image ?? '';
      _aadharNumberCtrl.text = user.aadharCard?.number ?? '';
      _aadharImageCtrl.text = user.aadharCard?.image ?? '';
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _avatarCtrl.dispose();
    _panNumberCtrl.dispose();
    _panImageCtrl.dispose();
    _aadharNumberCtrl.dispose();
    _aadharImageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = await context.read<UserProvider>().updateProfile(
          firstName: _firstCtrl.text.trim().isEmpty
              ? null
              : _firstCtrl.text.trim(),
          lastName: _lastCtrl.text.trim().isEmpty
              ? null
              : _lastCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty
              ? null
              : _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
          avatar: _avatarCtrl.text.trim().isEmpty
              ? null
              : _avatarCtrl.text.trim(),
          panNumber: _panNumberCtrl.text.trim().isEmpty
              ? null
              : _panNumberCtrl.text.trim(),
          panCardImage: _panImageCtrl.text.trim().isEmpty
              ? null
              : _panImageCtrl.text.trim(),
          aadharNumber: _aadharNumberCtrl.text.trim().isEmpty
              ? null
              : _aadharNumberCtrl.text.trim(),
          aadharCardImage: _aadharImageCtrl.text.trim().isEmpty
              ? null
              : _aadharImageCtrl.text.trim(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isVerified = context.watch<AuthProvider>().user?.isVerified ?? false;
    final updating = context.watch<UserProvider>().updating;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppStandardBar(
        title: 'Edit Profile',
        actions: [
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
              if (isVerified)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          color: cs.error, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Profile is locked after verification. Contact support to make changes.',
                          style: TextStyle(
                              color: cs.onErrorContainer, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              _Section('PERSONAL INFO'),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              AppInputField(
                label: 'AVATAR URL',
                controller: _avatarCtrl,
                hint: 'https://...',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 28),
              _Section('KYC VERIFICATION'),
              const SizedBox(height: 4),
              Text(
                'Submitting both PAN and Aadhar will trigger a verification request.',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'PAN NUMBER',
                controller: _panNumberCtrl,
                hint: 'ABCDE1234F',
                icon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'PAN CARD IMAGE URL',
                controller: _panImageCtrl,
                hint: 'https://...',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'AADHAR NUMBER',
                controller: _aadharNumberCtrl,
                hint: '1234 5678 9012',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppInputField(
                label: 'AADHAR CARD IMAGE URL',
                controller: _aadharImageCtrl,
                hint: 'https://...',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 32),
              AppPrimaryButton(
                text: 'SAVE CHANGES',
                onPressed: updating ? () {} : _save,
              ),
            ],
          ),
          if (updating) const AppLoader(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

  @override
  Widget build(BuildContext context) {
    return AppSectionLabel(text);
  }
}
