import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';

class CreateActivityBoardPage extends StatefulWidget {
  const CreateActivityBoardPage({super.key});

  @override
  State<CreateActivityBoardPage> createState() => _CreateActivityBoardPageState();
}

class _CreateActivityBoardPageState extends State<CreateActivityBoardPage> {
  String? _selectedSubType;

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
                        Text(
                          'Papan apa yang ingin kamu buat?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayL,
                        ),
                        const SizedBox(height: 32),
                        _buildOptionCard('Jadwal'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Atau',
                            style: AppTextStyles.displayM,
                          ),
                        ),
                        _buildOptionCard('First-Then'),
                        const SizedBox(height: 48),
                        _buildNextButton(),
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
          Text(
            'Buat Papan Aktivitas Baru',
            style: AppTextStyles.displayM,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String title) {
    final isSelected = _selectedSubType == title;
    final imageMap = {
      'Jadwal': 'assets/images/Sikat Gigi.png',
      'First-Then': 'assets/images/Mandi.png',
    };
    return GestureDetector(
      onTap: () => setState(() => _selectedSubType = title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.teal100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal700 : AppColors.neutral800.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                imageMap[title] ?? 'assets/images/Sikat Gigi.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.displayM,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = _selectedSubType != null;
    return GestureDetector(
      onTap: () {
        if (!isEnabled) return;
        
        // Routing logic
        if (_selectedSubType == 'Jadwal') {
          context.push(AppRoutes.createScheduleBoard);
        } else if (_selectedSubType == 'First-Then') {
          context.push(AppRoutes.createFirstThenBoard);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.peach500 : AppColors.peach100,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Text(
          'Selanjutnya',
          textAlign: TextAlign.center,
          style: AppTextStyles.displayM.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}