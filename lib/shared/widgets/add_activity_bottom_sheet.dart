import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/activity_catalog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/enums.dart';
import 'custom_icon.dart';

class AddActivityBottomSheet extends StatefulWidget {
  const AddActivityBottomSheet({super.key});

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  String _selectedCategory = 'Semua';
  String? _selectedActivity;

  static const _categoryLabels = {
    'Perawatan diri': ActivityCategory.selfCare,
    'Makan': ActivityCategory.meal,
    'Belajar': ActivityCategory.study,
    'Bermain': ActivityCategory.play,
    'Istirahat': ActivityCategory.bedtime,
  };

  List<ActivityCatalogItem> _filteredCatalog(String selectedCategory) {
    final category = _categoryLabels[selectedCategory];
    if (category == null) return ActivityCatalog.items;
    return ActivityCatalog.items.where((item) => item.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Semua', 'Perawatan diri', 'Makan', 'Belajar', 
      'Transisi', 'Bermain', 'Sosial', 'Istirahat', 'Menunggu', 'Emosi'
    ];

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      width: double.infinity, 
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 24 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFCFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar 
          Center(
            child: Container(
              width: 144,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tambahkan Aktivitas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pop(); 
                  context.push(AppRoutes.createActivity); 
                },
                child: Row(
                  children: const [
                    CustomIcon(
                      assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                      size: 22,
                      color: Color(0xFFC4806C),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Buat Baru',
                      style: TextStyle(
                        color: Color(0xFFC4806C),
                        fontSize: 20,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chips Kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF446860) : const Color(0xFF7EA29C),
                        borderRadius: BorderRadius.circular(36),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 8),

          // Grid Aktivitas
          Expanded(
            child: Builder(builder: (context) {
              final items = _filteredCatalog(_selectedCategory);
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = _selectedActivity == item.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedActivity = item.id;
                      });
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.neutral300,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: const Color(0xFF446860), width: 4)
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Image.asset(item.image, fit: BoxFit.contain),
                                if (isSelected)
                                  const Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(Icons.check_circle, color: Color(0xFF446860)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (_selectedActivity == null) return; 
              Navigator.pop(context, _selectedActivity); 
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedActivity != null ? AppColors.peach500 : AppColors.peach100,
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Text(
                'Selanjutnya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}