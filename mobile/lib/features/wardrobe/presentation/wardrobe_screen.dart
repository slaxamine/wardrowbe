import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wardrobe', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip('All', true),
                _categoryChip('Tops', false),
                _categoryChip('Bottoms', false),
                _categoryChip('Shoes', false),
                _categoryChip('Outerwear', false),
                _categoryChip('Accessories', false),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 12, // Placeholder count
              itemBuilder: (context, index) => _buildItemCard(context, index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open camera/gallery picker
        },
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.darkBg,
        icon: const Icon(Icons.camera_alt),
        label: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _categoryChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.gold,
        labelStyle: TextStyle(
          color: selected ? AppColors.darkBg : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, int index) {
    final colors = [
      Colors.blueGrey,
      Colors.brown,
      Colors.indigo,
      Colors.teal,
      Colors.deepPurple,
      Colors.amber,
    ];

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to item detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors[index % colors.length].withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.checkroom, size: 40, color: colors[index % colors.length]),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'Item ${index + 1}',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
