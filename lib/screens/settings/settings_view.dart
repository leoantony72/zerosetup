import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _authService = AuthService();
  final _settingsService = SettingsService();
  String _downloadPath = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final path = await _settingsService.getDownloadPath();
    if (mounted) {
      setState(() => _downloadPath = path);
    }
  }

  Future<void> _pickDownloadPath() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await _settingsService.setDownloadPath(result);
      setState(() => _downloadPath = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final user = _authService.currentUser;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your account and application preferences',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            // ── Account Section ─────────────────────────────────────────────
            _buildSectionHeader('Account', Icons.person_outline_rounded),
            const SizedBox(height: 24),
            _buildAccountCard(user),
            const SizedBox(height: 48),

            // ── Storage Section ─────────────────────────────────────────────
            _buildSectionHeader('Storage', Icons.storage_rounded),
            const SizedBox(height: 24),
            _buildStorageCard(),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.emerald700),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: user == null ? _buildLoggedOutState() : _buildLoggedInState(user),
    );
  }

  Widget _buildLoggedInState(User user) {
    final metadata = user.userMetadata ?? {};
    final fullName = metadata['full_name'] ?? 'Guest User';
    final avatarUrl = metadata['avatar_url'];

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.emerald100,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null 
            ? Icon(Icons.person, color: AppColors.emerald700, size: 32)
            : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () => _authService.signOut(),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Sign Out'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOutState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign in to sync your library',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Connect with Google or GitHub to access your workflows across devices.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildSocialButton(
              'Google',
              Icons.g_mobiledata_rounded,
              () => _authService.signInWithGoogle(),
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              'GitHub',
              Icons.code_rounded,
              () => _authService.signInWithGithub(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text('Continue with $label'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleArray(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.folder_open_rounded, color: AppColors.slate500),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Download Location',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _downloadPath,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _pickDownloadPath,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald700,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleArray(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

// Helper to use rounded rectangles with circular corners in buttons
class RoundedRectangleArray extends RoundedRectangleBorder {
  const RoundedRectangleArray({required BorderRadius borderRadius}) : super(borderRadius: borderRadius);
}
