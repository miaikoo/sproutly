import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../shared/widgets/custom_icon.dart';

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
                        const Text(
                          'Papan apa yang ingin kamu buat?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                          ),
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
          const Text(
            'Buat Papan Baru',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String title) {
    final isSelected = _selectedType == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.teal100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF446860) : AppColors.neutral800.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF446860) : AppColors.neutral800.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Color(0xFF446860), shape: BoxShape.circle)))
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
        
        if (_selectedType == 'Aktivitas') {
          context.push(AppRoutes.createBoardActivity);
        } else {
          print('Lanjut ke $_selectedType');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.peach500 : AppColors.peach100,
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
    );
  }
}