import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Profile'),
          _settingsTile(Icons.person, 'Edit Profile', () {}),
          _settingsTile(Icons.location_on, 'Set Location', () {}),
          _settingsTile(Icons.straighten, 'Body Measurements', () {}),
          const SizedBox(height: 24),
          _sectionTitle('Preferences'),
          _settingsTile(Icons.palette, 'Color Preferences', () {}),
          _settingsTile(Icons.style, 'Style Profile', () {}),
          _settingsTile(Icons.thermostat, 'Temperature Settings', () {}),
          const SizedBox(height: 24),
          _sectionTitle('Notifications'),
          _settingsTile(Icons.notifications, 'Notification Settings', () {}),
          _settingsTile(Icons.schedule, 'Outfit Schedule', () {}),
          const SizedBox(height: 24),
          _sectionTitle('AI'),
          _settingsTile(Icons.smart_toy, 'AI Endpoints', () {}),
          const SizedBox(height: 24),
          _sectionTitle('Family'),
          _settingsTile(Icons.group, 'Manage Family', () {}),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(color: AppColors.error, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'wardrowbe v1.0.0',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.darkSubtext),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkSubtext, size: 22),
      title: Text(title, style: GoogleFonts.inter(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.darkSubtext),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
