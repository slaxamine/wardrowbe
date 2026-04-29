import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';
import 'package:wardrowbe_app/features/auth/data/auth_service.dart';
import 'package:wardrowbe_app/features/wardrobe/data/wardrobe_service.dart';
import 'package:wardrowbe_app/features/outfits/data/outfit_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wardrobeProvider.notifier).loadItems();
      ref.read(outfitProvider.notifier).loadTodayOutfit();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final wardrobeState = ref.watch(wardrobeProvider);
    final outfitState = ref.watch(outfitProvider);
    final userName = authState.user?['displayName'] ?? authState.user?['username'] ?? 'there';
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, $userName ✨',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              DateFormat('EEEE, d MMMM').format(now),
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkSubtext),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(wardrobeProvider.notifier).loadItems();
          await ref.read(outfitProvider.notifier).loadTodayOutfit();
        },
        color: AppColors.gold,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather card
              _buildWeatherCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              // Today's outfit card
              _buildTodayOutfitCard(outfitState).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              // Quick stats
              _buildQuickStats(wardrobeState).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              // Quick actions
              Text(
                'Quick Actions',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildQuickActions().animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.wb_sunny, size: 24, color: AppColors.gold),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '22°C — Partly Cloudy',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Great day for layering',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkSubtext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayOutfitCard(OutfitState outfitState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  "Today's Outfit",
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (outfitState.currentSuggestion != null) ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.1),
                      AppColors.goldDark.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom, size: 32, color: AppColors.gold.withValues(alpha: 0.7)),
                      const SizedBox(width: 8),
                      Icon(Icons.add, size: 16, color: AppColors.darkSubtext),
                      const SizedBox(width: 8),
                      Icon(Icons.style, size: 32, color: AppColors.gold.withValues(alpha: 0.7)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.darkBg.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No outfit suggested yet.\nTap to get one!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.darkSubtext, fontSize: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/suggest'),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Get Suggestion'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(WardrobeState wardrobeState) {
    return Row(
      children: [
        Expanded(child: _statCard('${wardrobeState.totalItems}', 'Items', Icons.checkroom)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('0', 'Outfits', Icons.style)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('${wardrobeState.needsWashCount}', 'Needs Wash', Icons.local_laundry_service)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkSubtext),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _actionChip(Icons.camera_alt, 'Add Item', () => context.go('/wardrobe')),
        _actionChip(Icons.auto_awesome, 'Suggest', () => context.go('/suggest')),
        _actionChip(Icons.history, 'History', () => context.go('/history')),
        _actionChip(Icons.settings, 'Settings', () => context.go('/settings')),
      ],
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.gold),
      label: Text(label, style: GoogleFonts.inter(fontSize: 13)),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
