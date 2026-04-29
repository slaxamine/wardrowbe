import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening ✨',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Wednesday, 23 April',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.darkSubtext,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weather card
            _buildWeatherCard(context),
            const SizedBox(height: 16),
            // Today's outfit card
            _buildTodayOutfitCard(context),
            const SizedBox(height: 24),
            // Quick stats
            _buildQuickStats(context),
            const SizedBox(height: 24),
            // Quick actions
            Text(
              'Quick Actions',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny, size: 40, color: AppColors.gold),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '22°C — Partly Cloudy',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Feels like 20°C • 15% rain chance',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.darkSubtext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayOutfitCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Today's Outfit",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.darkBg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No outfit suggested yet.\nTap to get one!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppColors.darkSubtext,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Get Suggestion'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard('47', 'Items', Icons.checkroom)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('12', 'Outfits', Icons.style)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('3', 'Need Wash', Icons.local_laundry_service)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.darkSubtext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _actionChip(Icons.camera_alt, 'Add Item'),
        _actionChip(Icons.auto_awesome, 'Suggest'),
        _actionChip(Icons.analytics, 'Analytics'),
        _actionChip(Icons.group, 'Family'),
      ],
    );
  }

  Widget _actionChip(IconData icon, String label) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.gold),
      label: Text(label),
      onPressed: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
