import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_icon.dart';

class CreateActivityPage extends StatelessWidget {
  const CreateActivityPage({super.key});

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
                        _buildActionButtons(),
                        const SizedBox(height: 32),
                        const Text(
                          'KATEGORI',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.56,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCategoryChips(),
                        const SizedBox(height: 32),
                        _buildSettingsSection(),
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
            'Buat Aktivitas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFD2E2EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mandi',
            style: TextStyle(
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChipButton('Ganti Gambar'),
            _buildChipButton('Tambah Suara'),
            _buildChipButton('Tambah Video'),
          ],
        ),
      ],
    );
  }

  Widget _buildChipButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF446860),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 16,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'Perawatan diri', 'Makan', 'Belajar', 'Transisi', 
      'Bermain', 'Sosial', 'Istirahat', 'Menunggu', 'Emosi', 'Lainnya'
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF7EA29C),
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
        );
      }).toList(),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PENGATURAN',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.56,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Durasi default (opsional)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD2E2EE),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Text(
                '00 Menit 00 Detik',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Verifikasi aktivitas dengan AI',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: false,
              onChanged: (val) {},
              activeThumbColor: const Color(0xFF5E8880),
            ),
          ],
        ),
      ],
    );
  }
}