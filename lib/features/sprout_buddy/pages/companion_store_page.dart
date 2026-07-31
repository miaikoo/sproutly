import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/companion_progress.dart';
import '../../../core/data/store_catalog.dart';
import '../../../core/services/child_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/child.dart';


enum StoreCategory {
  clothing('Pakaian', Color(0xFFEDF3F7), Color(0xFF8AAABF)),
  hats('Aksesoris Head', Color(0xFFE8DFC0), Color(0xFFC4B878)),
  glasses('Kacamata', Color(0xFFEECABC), Color(0xFFC4806C)),
  footwear('Sepatu', Color(0xFFB5CCDE), Color(0xFF7EA29C)),
  others('Lainnya', Color(0xFFBCA0B0), Color(0xFFA88898));

  const StoreCategory(this.label, this.tabColor, this.borderColor);
  final String label;
  final Color tabColor;
  final Color borderColor;
}

class CompanionStorePage extends ConsumerStatefulWidget {
  const CompanionStorePage({super.key});

  @override
  ConsumerState<CompanionStorePage> createState() => _CompanionStorePageState();
}

class _CompanionStorePageState extends ConsumerState<CompanionStorePage> {
  StoreCategory _selectedCategory = StoreCategory.clothing;

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFB5CCDE),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: childAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat toko: $e')),
              data: (child) => child == null
                  ? const Center(child: Text('Profil anak belum tersedia.'))
                  : _buildStoreView(child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreView(Child child) {
    final level = levelForExp(child.exp);

    return Stack(
      children: [
        // Top Room Section with Decor Assets & Buddy Mascot
        Positioned.fill(
          bottom: 420,
          child: _buildRoomScene(level),
        ),

        // Header (Back Button, Title, Points Pill)
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9ABCB6).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        offset: const Offset(0, 3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Text(
                'Toko Aksesoris',
                style: AppTextStyles.displayL.copyWith(
                  color: const Color(0xFF2C3E3A),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '${child.points}',
                      style: AppTextStyles.headingM.copyWith(
                        color: const Color(0xFF2C3E3A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Folder Tabs & Item Container
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 440,
          child: _buildFolderSheet(child),
        ),
      ],
    );
  }

  Widget _buildRoomScene(int level) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8AAABF),
            Color(0xFFB5CCDE),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Window Asset (Top Right)
          Positioned(
            top: 20,
            right: 20,
            child: Image.asset(
              'assets/images/jendela.png',
              width: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.window, size: 80, color: Colors.white54),
            ),
          ),

          // 2. Drawer Asset (Middle Left)
          Positioned(
            left: 12,
            bottom: 60,
            child: Image.asset(
              'assets/images/drawer.png',
              width: 110,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.table_restaurant, size: 60, color: Colors.white54),
            ),
          ),

          // 3. Carpet Ellipse (Base floor under Buddy)
          Positioned(
            bottom: 25,
            child: Image.asset(
              'assets/images/Carpet.png',
              width: 280,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
                width: 260,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFBCA0B0).withValues(alpha: 0.6),
                  borderRadius: const BorderRadius.all(Radius.elliptical(260, 100)),
                ),
              ),
            ),
          ),

          // 4. Buddy Character & Sparkles
          Positioned(
            bottom: 50,
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/images/Bahagia.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const Positioned(
                    top: 10,
                    left: 2,
                    child: Text('✨', style: TextStyle(fontSize: 24)),
                  ),
                  const Positioned(
                    top: 18,
                    right: 2,
                    child: Text('✨', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSheet(Child child) {
    return Column(
      children: [
        // Horizontal Folder Tabs
        SizedBox(
          height: 42,
          child: Row(
            children: StoreCategory.values.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEDF3F7) : cat.tabColor.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF8AAABF) : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelM.copyWith(
                        color: isSelected ? const Color(0xFF2C3E3A) : const Color(0xFF566866),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Folder Content Area
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFEDF3F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              border: Border(
                top: BorderSide(color: Color(0xFF8AAABF), width: 1.5),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildItemsGrid(child),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(Child child) {
    // Filter item catalog based on tab selection
    final filteredCatalog = storeCatalog.where((item) {
      switch (_selectedCategory) {
        case StoreCategory.clothing:
          return item.id == 'overalls';
        case StoreCategory.hats:
          return item.id == 'hat' || item.id == 'crown';
        case StoreCategory.glasses:
          return item.id == 'glasses';
        case StoreCategory.footwear:
          return item.id == 'boots';
        case StoreCategory.others:
          return item.id == 'scarf' || item.id == 'umbrella' || item.id == 'backpack';
      }
    }).toList();

    // Fill with repeated items to simulate complete grid if category list is small
    final itemsToDisplay = filteredCatalog.isEmpty
        ? storeCatalog
        : List.generate(
            12,
            (index) => filteredCatalog[index % filteredCatalog.length],
          );

    return GridView.builder(
      itemCount: itemsToDisplay.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = itemsToDisplay[index];
        final isFirstItem = index == 0; // highlight selected item like design mock
        final owned = child.unlockedItemIds.contains(item.id);

        return GestureDetector(
          onTap: owned ? null : () => _buy(context, ref, child, item),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isFirstItem ? const Color(0xFFC4B878) : Colors.transparent,
                width: isFirstItem ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.name,
                  style: AppTextStyles.labelS.copyWith(
                    color: const Color(0xFF2C3E3A),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, Child child, StoreItem item) async {
    try {
      await ref
          .read(childServiceProvider)
          .purchaseItem(child.id, itemId: item.id, cost: item.cost);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} berhasil dibeli!')),
        );
      }
    } on StateError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}
