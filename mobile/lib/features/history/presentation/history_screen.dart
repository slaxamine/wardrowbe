import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outfit History', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.gold.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No outfit history yet',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.darkSubtext),
            ),
            const SizedBox(height: 8),
            Text(
              'Your accepted outfits will appear here\nwith a calendar view.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkSubtext),
            ),
          ],
        ),
      ),
    );
  }
}
