import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/add_activity_bottom_sheet.dart'; 

class CreateFirstThenBoardPage extends StatelessWidget {
  const CreateFirstThenBoardPage({super.key});

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
                      children: [
                        _buildStepCard(context, 'pertama aku perlu...'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CustomIcon(
                            assetName: 'assets/icons/down_arrow.svg',
                            size: 40,
                            color: Color(0xFFC4806C),
                          ),
                        ),
                        _buildStepCard(context, 'kemudian aku bisa...'),
                      ],
                    ),
                  ),
                ),
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
            'Mandi',
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

  Widget _buildStepCard(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD2E2EE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showAddActivityModal(context), 
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.5), 
                border: Border.all(color: const Color(0xFF7B9DB8), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CustomIcon(
                  assetName: 'assets/icons/solar_clipboard-add-outline.svg',
                  size: 36,
                  color: Color(0xFF7B9DB8),
                ),
              ),
            ),
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
      print('Aktivitas yang dipilih dari First-Then: $result');
    }
  }
}