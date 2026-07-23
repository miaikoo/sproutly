import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../shared/widgets/custom_icon.dart';

class CreateScheduleBoardPage extends StatelessWidget {
  const CreateScheduleBoardPage({super.key});

    @override
      Widget build(BuildContext context) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleCard(),
                            const SizedBox(height: 24),
                            _buildScheduleItemCard(context),
                            const SizedBox(height: 24),
                            _buildAddButton(context),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Gunakan Template',
                                style: TextStyle(
                                  color: AppColors.neutral800.withOpacity(0.7),
                                  fontSize: 18,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomSection(context),
                  ],
                ),
              ),
            ),
          ),
        );
      }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const CustomIcon(
              assetName: 'assets/icons/solar_alt-arrow-left-outline.svg',
              size: 28,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Rutinitas Pagi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const CustomIcon(
            assetName: 'assets/icons/solar_settings-bold.svg',
            size: 28,
            color: AppColors.neutral800,
          ),
          const SizedBox(width: 16),
          const CustomIcon(
            assetName: 'assets/icons/lucide_save.svg',
            size: 28,
            color: AppColors.neutral800,
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFD2E2EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rutinitas Pagi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const CustomIcon(
                  assetName: 'assets/icons/solar_pen-linear.svg',
                  size: 24,
                  color: AppColors.neutral800,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItemCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD2E2EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Pertama, aku harus', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
              Text('Timer', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
              Text('Selesai', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showAddActivityModal(context), // Pop up sheet
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF7B9DB8), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CustomIcon(
                        assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                        size: 28,
                        color: Color(0xFF7B9DB8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B9DB8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '05:00',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B9DB8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddActivityModal(context), // Open pop-up sheet
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFA88898),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CustomIcon(
              assetName: 'assets/icons/solar_clipboard-add-outline.svg',
              size: 24,
              color: AppColors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Tambahkan Kegiatan',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF7B9DB8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'kemudian aku bisa melakukan...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showAddActivityModal(context),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD2E2EE), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CustomIcon(
                      assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                      size: 28,
                      color: Color(0xFFD2E2EE),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Atau',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showAddActivityModal(context),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD2E2EE), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CustomIcon(
                      assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                      size: 28,
                      color: Color(0xFFD2E2EE),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddActivityModal(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: const AddActivityBottomSheet(),
        ),
      ),
    );

    if (result != null) {
      print('Aktivitas yang dipilih: $result');
    }
  }
}

class AddActivityBottomSheet extends StatefulWidget {
  const AddActivityBottomSheet({super.key});

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  String _selectedCategory = 'Semua';
  String? _selectedActivity;

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Semua', 'Perawatan diri', 'Makan', 'Belajar', 
      'Transisi', 'Bermain', 'Sosial', 'Istirahat', 'Menunggu', 'Emosi'
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          
          // Header Sheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tambahkan Aktvitas',
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

          // Category (Horizontal Scrollable Chips)
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

          // Activity Grid 
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final activityName = 'Aktivitas ${index + 1}';
                final isSelected = _selectedActivity == activityName;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedActivity = activityName;
                    });
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: const Color(0xFF446860), width: 4)
                                : null,
                          ),
                          child: isSelected
                              ? const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.check_circle, color: Color(0xFF446860)),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activityName,
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
            ),
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