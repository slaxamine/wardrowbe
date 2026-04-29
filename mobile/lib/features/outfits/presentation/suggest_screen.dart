import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';
import 'package:wardrowbe_app/features/outfits/data/outfit_service.dart';

class SuggestScreen extends ConsumerStatefulWidget {
  const SuggestScreen({super.key});

  @override
  ConsumerState<SuggestScreen> createState() => _SuggestScreenState();
}

class _SuggestScreenState extends ConsumerState<SuggestScreen> {
  String _selectedOccasion = 'CASUAL';
  final _occasions = [
    {'key': 'CASUAL', 'label': 'Casual', 'icon': Icons.weekend},
    {'key': 'OFFICE', 'label': 'Office', 'icon': Icons.work},
    {'key': 'FORMAL', 'label': 'Formal', 'icon': Icons.diamond},
    {'key': 'DATE', 'label': 'Date', 'icon': Icons.favorite},
    {'key': 'SPORTY', 'label': 'Sporty', 'icon': Icons.fitness_center},
    {'key': 'OUTDOOR', 'label': 'Outdoor', 'icon': Icons.park},
  ];

  @override
  Widget build(BuildContext context) {
    final outfitState = ref.watch(outfitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('What to Wear', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Occasion',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkSubtext, fontWeight: FontWeight.w500),
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _occasions.map((o) {
                final key = o['key'] as String;
                final selected = key == _selectedOccasion;
                return ChoiceChip(
                  avatar: Icon(o['icon'] as IconData, size: 18, color: selected ? AppColors.darkBg : AppColors.gold),
                  label: Text(o['label'] as String),
                  selected: selected,
                  selectedColor: AppColors.gold,
                  labelStyle: GoogleFonts.inter(
                    color: selected ? AppColors.darkBg : null,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (_) => setState(() => _selectedOccasion = key),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),
            // Weather info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.wb_sunny, color: AppColors.gold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('22°C — Partly Cloudy',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            // Suggestion result
            if (outfitState.currentSuggestion != null) ...[
              _buildSuggestionCard(outfitState.currentSuggestion!).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final id = outfitState.currentSuggestion!['id']?.toString();
                        if (id != null) ref.read(outfitProvider.notifier).respond(id, false);
                        ref.read(outfitProvider.notifier).clearSuggestion();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Try Again'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkSubtext,
                        side: BorderSide(color: AppColors.darkSubtext.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final id = outfitState.currentSuggestion!['id']?.toString();
                        if (id != null) ref.read(outfitProvider.notifier).respond(id, true);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Wear This'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ],

            const Spacer(),
            // Generate button
            if (outfitState.currentSuggestion == null)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: outfitState.isLoading
                      ? null
                      : () => ref.read(outfitProvider.notifier).suggest(occasion: _selectedOccasion),
                  icon: outfitState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.darkBg)),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    outfitState.isLoading ? 'Thinking...' : 'Generate Outfit',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final items = suggestion['items'] as List<dynamic>? ?? [];
    final occasion = suggestion['occasion'] ?? _selectedOccasion;

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
                  'AI Suggestion',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    occasion.toString(),
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isNotEmpty)
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.checkroom, size: 18, color: AppColors.gold),
                        const SizedBox(width: 10),
                        Text(
                          item['name']?.toString() ?? 'Item',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ],
                    ),
                  ))
            else
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.darkBg.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Outfit suggestion generated!',
                    style: GoogleFonts.inter(color: AppColors.darkSubtext),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
