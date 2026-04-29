import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wardrowbe_app/core/theme/app_theme.dart';
import 'package:wardrowbe_app/features/wardrobe/data/wardrobe_service.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'TOP', 'BOTTOM', 'SHOES', 'OUTERWEAR', 'ACCESSORY'];
  final _categoryLabels = {
    'All': 'All',
    'TOP': 'Tops',
    'BOTTOM': 'Bottoms',
    'SHOES': 'Shoes',
    'OUTERWEAR': 'Outerwear',
    'ACCESSORY': 'Accessories',
  };

  @override
  void initState() {
    super.initState();
    // Load items on first build
    Future.microtask(() => ref.read(wardrobeProvider.notifier).loadItems());
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkSubtext.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add New Item',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.darkText),
            ),
            const SizedBox(height: 16),
            // Camera placeholder
            GestureDetector(
              onTap: () {
                // TODO: Open camera/gallery
              },
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.gold.withValues(alpha: 0.7)),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to take a photo',
                      style: GoogleFonts.inter(color: AppColors.darkSubtext, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Item Name',
                labelStyle: GoogleFonts.inter(color: AppColors.darkSubtext),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
              style: GoogleFonts.inter(color: AppColors.darkText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final success = await ref.read(wardrobeProvider.notifier).addItem(name: nameCtrl.text.trim());
                    if (success && ctx.mounted) Navigator.pop(ctx);
                  }
                },
                icon: const Icon(Icons.add, size: 20),
                label: Text('Add to Wardrobe', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeState = ref.watch(wardrobeProvider);
    final filteredItems = wardrobeState.filterByType(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Wardrobe', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600)),
            Text(
              '${wardrobeState.totalItems} items',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.darkSubtext),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final selected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categoryLabels[cat] ?? cat),
                    selected: selected,
                    selectedColor: AppColors.gold,
                    labelStyle: GoogleFonts.inter(
                      color: selected ? AppColors.darkBg : AppColors.darkText,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Items grid
          Expanded(
            child: wardrobeState.isLoading
                ? _buildShimmerGrid()
                : filteredItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => ref.read(wardrobeProvider.notifier).loadItems(),
                        color: AppColors.gold,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) =>
                              _buildItemCard(filteredItems[index], index),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.darkBg,
        icon: const Icon(Icons.camera_alt, size: 20),
        label: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 1),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final colors = [
      Colors.blueGrey,
      Colors.brown,
      Colors.indigo,
      Colors.teal,
      Colors.deepPurple,
      Colors.amber,
    ];
    final color = colors[index % colors.length];
    final name = item['name'] ?? 'Item';
    final type = item['type'] ?? '';
    final wearCount = item['wearCount'] ?? 0;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to item detail
      },
      onLongPress: () {
        // Show quick actions
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.darkCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.checkroom, color: AppColors.gold),
                  title: Text('Log Wear', style: GoogleFonts.inter()),
                  onTap: () {
                    ref.read(wardrobeProvider.notifier).logWear(item['id'].toString());
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_laundry_service, color: AppColors.info),
                  title: Text('Mark Washed', style: GoogleFonts.inter()),
                  onTap: () {
                    ref.read(wardrobeProvider.notifier).markWashed(item['id'].toString());
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text('Delete', style: GoogleFonts.inter(color: AppColors.error)),
                  onTap: () {
                    ref.read(wardrobeProvider.notifier).deleteItem(item['id'].toString());
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            Icon(Icons.checkroom, size: 36, color: color.withValues(alpha: 0.8)),
            if (wearCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${wearCount}x worn',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.darkSubtext),
                ),
              ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkText, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (type.isNotEmpty)
                    Text(
                      type,
                      style: GoogleFonts.inter(fontSize: 9, color: AppColors.darkSubtext),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom, size: 64, color: AppColors.gold.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Your wardrobe is empty',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first item',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.darkSubtext),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurface,
      highlightColor: AppColors.darkCard,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
