import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/add_activity_bottom_sheet.dart';

class CreateScheduleBoardPage extends StatefulWidget {
  const CreateScheduleBoardPage({super.key});

  @override
  State<CreateScheduleBoardPage> createState() => _CreateScheduleBoardPageState();
}

class _CreateScheduleBoardPageState extends State<CreateScheduleBoardPage> {
  int _activityCount = 1; 

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
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2E2EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _activityCount,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) => _buildScheduleRow(context, index),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        _buildAddButton(),
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
              children: const [
                Text(
                  'Rutinitas Pagi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomIcon(
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

  Widget _buildScheduleRow(BuildContext context, int index) {
    return Column(
      children: [
        if (index == 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Pertama, aku harus', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
              Text('Timer', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
              Text('Selesai', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showAddActivityModal(context), 
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.5), 
                    border: Border.all(color: const Color(0xFF7B9DB8), width: 1.5),
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
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activityCount++;
        });
      },
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
                    color: AppColors.white.withOpacity(0.2),
                    border: Border.all(color: const Color(0xFFD2E2EE), width: 1.5),
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
                    color: AppColors.white.withOpacity(0.2),
                    border: Border.all(color: const Color(0xFFD2E2EE), width: 1.5),
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
      print('Aktivitas yang dipilih dari Pop-Up: $result');
    }
  }
}