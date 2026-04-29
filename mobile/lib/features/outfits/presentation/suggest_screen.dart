import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';

class SuggestScreen extends StatelessWidget {
  const SuggestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What to Wear', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Occasion selector
            Text(
              'Select Occasion',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.darkSubtext),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _occasionChip('Casual', Icons.weekend, true),
                _occasionChip('Office', Icons.work, false),
                _occasionChip('Formal', Icons.diamond, false),
                _occasionChip('Date', Icons.favorite, false),
                _occasionChip('Sporty', Icons.fitness_center, false),
                _occasionChip('Outdoor', Icons.park, false),
              ],
            ),
            const SizedBox(height: 24),
            // Weather info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: AppColors.gold),
                    const SizedBox(width: 12),
                    Text('22°C — Partly Cloudy',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Generate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Call outfit-service /suggest endpoint
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text('Generate Outfit',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _occasionChip(String label, IconData icon, bool selected) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: selected ? AppColors.darkBg : AppColors.gold),
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.gold,
      labelStyle: TextStyle(
        color: selected ? AppColors.darkBg : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
