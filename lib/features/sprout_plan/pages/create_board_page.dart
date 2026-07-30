import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../core/theme/app_text_styles.dart';

class CreateBoardPage extends StatefulWidget {
  const CreateBoardPage({super.key});

  @override
  State<CreateBoardPage> createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  String? _selectedType;

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
                        _buildOptionCard('Aktivitas'),
                        const SizedBox(height: 16),
                        _buildOptionCard('Menunggu'),
                        const SizedBox(height: 16),
                        _buildOptionCard('Emosi'),
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
            'Buat Papan Baru',
            style: AppTextStyles.displayM,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String title) {
    final isSelected = _selectedType == title;
    
    final imageMap = {
      'Aktivitas': 'assets/images/Belajar.png',
      'Menunggu': 'assets/images/Menunggu.png',
      'Emosi': 'assets/images/Bahagia.png', 
    };

    return GestureDetector(
      onTap: () => setState(() => _selectedType = title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.teal100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Ganti AppColors.teal700 jadi AppColors.teal700 (atau warna gelap andalanmu)
            color: isSelected ? AppColors.teal700 : AppColors.neutral800.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                imageMap[title] ?? 'assets/images/Bahagia.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 24),
            
            // Text Title
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.displayM,
              ),
            ),
            
            // Custom Radio Button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.teal700 : AppColors.neutral800.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 16, 
                        height: 16, 
                        decoration: const BoxDecoration(
                          color: AppColors.teal700, 
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = _selectedType != null;
    return GestureDetector(
      onTap: () {
        if (!isEnabled) return;
        
        // Cek pilihan dan lempar ke route yang sesuai
        if (_selectedType == 'Aktivitas') {
          context.push(AppRoutes.createBoardActivity);
        } else if (_selectedType == 'Menunggu') {
          context.push(AppRoutes.createWaitingBoard); // <--- Arahkan ke Waiting Board
        } else if (_selectedType == 'Emosi') {
          context.push(AppRoutes.createEmotionBoard); // <--- Arahkan ke Emotion Board
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