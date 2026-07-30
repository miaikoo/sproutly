import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AccessibilitySettingsPage extends StatefulWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  State<AccessibilitySettingsPage> createState() => _AccessibilitySettingsPageState();
}

class _AccessibilitySettingsPageState extends State<AccessibilitySettingsPage> {
  double _textSize = 1.0;
  double _iconSize = 1.0;
  bool _highContrast = false;
  bool _reduceAnimations = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aksesibilitas', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sesuaikan tampilan Sprout.ly untuk kenyamanan visual anak Anda.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              // Preview Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _highContrast ? Colors.black : AppColors.teal50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _highContrast ? Colors.white : AppColors.teal200,
                    width: _highContrast ? 3 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'PREVIEW TAMPILAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _highContrast ? Colors.yellow : AppColors.teal800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 36 * _iconSize,
                          color: _highContrast ? Colors.yellow : const Color(0xFFC4806C),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Belajar Mandi Mandiri',
                            style: AppTextStyles.headingL.copyWith(
                              fontSize: (AppTextStyles.headingL.fontSize ?? 20) * _textSize,
                              color: _highContrast ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Text Size Slider
              _buildSliderSection(
                title: 'Ukuran Teks',
                subtitle: 'Perbesar atau perkecil teks di seluruh aplikasi.',
                value: _textSize,
                min: 0.8,
                max: 1.4,
                onChanged: (val) => setState(() => _textSize = val),
              ),
              const SizedBox(height: 24),

              // Icon Size Slider
              _buildSliderSection(
                title: 'Ukuran Ikon & Gambar',
                subtitle: 'Menyesuaikan ukuran tombol visual schedule.',
                value: _iconSize,
                min: 0.8,
                max: 1.4,
                onChanged: (val) => setState(() => _iconSize = val),
              ),
              const SizedBox(height: 24),

              // Switches Section
              _buildSwitchRow(
                title: 'Mode Kontras Tinggi',
                subtitle: 'Membantu anak dengan kepekaan visual rendah.',
                value: _highContrast,
                onChanged: (val) => setState(() => _highContrast = val),
              ),
              const SizedBox(height: 16),
              
              _buildSwitchRow(
                title: 'Kurangi Animasi',
                subtitle: 'Mengurangi gerakan layar untuk menghindari distorsi.',
                value: _reduceAnimations,
                onChanged: (val) => setState(() => _reduceAnimations = val),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.teal800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengaturan aksesibilitas berhasil disimpan!')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan Pengaturan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingL),
        Text(subtitle, style: AppTextStyles.bodyS),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 6,
          activeColor: AppColors.teal800,
          inactiveColor: AppColors.teal100,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headingL),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodyS),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.teal800,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
