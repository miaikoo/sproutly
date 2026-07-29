import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/add_activity_bottom_sheet.dart';

class CreateWaitingBoardPage extends StatelessWidget {
  const CreateWaitingBoardPage({super.key});

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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildTitleInput('Menunggu', AppColors.olive100),
                              const SizedBox(height: 32),
                              
                              const Text(
                                'Aku',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildAddBox(context, borderColor: AppColors.olive500),
                              const SizedBox(height: 16),
                              
                              const Text(
                                'selama',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              _buildTimerCircle(),
                            ],
                          ),
                        ),
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
            'Menunggu',
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
            color: AppColors.olive500, 
          ),
          const SizedBox(width: 16),
          const CustomIcon(
            assetName: 'assets/icons/lucide_save.svg',
            size: 28,
            color: AppColors.olive500, 
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput(String title, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
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
    );
  }

  Widget _buildTimerCircle() {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        color: AppColors.olive100,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.olive700,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '05:00',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 28,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.olive500,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'kemudian aku bisa melakukan...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAddBox(context, borderColor: AppColors.white),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Atau',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildAddBox(context, borderColor: AppColors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddBox(BuildContext context, {required Color borderColor}) {
    return GestureDetector(
      onTap: () => _showAddActivityModal(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.3), 
          border: Border.all(color: borderColor, width: 2), 
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 40,
            color: borderColor,
          ),
        ),
      ),
    );
  }

  void _showAddActivityModal(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Align( // <-- Hapus const di sini kalau sebelumnya ada
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // <-- Tambahin const di sini
          child: const SafeArea( // <-- Tambahin const di sini
            bottom: false,
            child: AddActivityBottomSheet(),
          ),
        ),
      ),
    );

    if (result != null) {
      print('Aktivitas: $result');
    }
  }
}