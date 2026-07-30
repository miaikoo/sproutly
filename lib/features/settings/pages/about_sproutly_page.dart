import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AboutSproutlyPage extends StatelessWidget {
  const AboutSproutlyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tentang Sprout.ly', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Center(
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.displayL.copyWith(
                          color: const Color(0xFF5E8880),
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                        children: const [
                          TextSpan(text: 'Sprout'),
                          TextSpan(text: '.', style: TextStyle(color: Color(0xFFC4806C))),
                          TextSpan(text: 'ly'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versi 1.0.0',
                      style: AppTextStyles.bodyS.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Apa itu Sprout.ly?',
                style: AppTextStyles.headingL.copyWith(color: AppColors.teal800),
              ),
              const SizedBox(height: 8),
              Text(
                'Sprout.ly adalah platform home-based intervention berbasis Artificial Intelligence (AI) yang dirancang khusus untuk meningkatkan kemandirian anak dengan Autism Spectrum Disorder (ASD). Melalui metodologi intervensi terstruktur seperti Early Intensive Behavioral Intervention (EIBI), Sprout.ly membantu anak menguasai Daily Living Skills (DLS) secara bertahap.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text(
                'Modul Utama Kami',
                style: AppTextStyles.headingL.copyWith(color: AppColors.teal800),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem('SproutPlan', 'Visual schedule untuk menyusun aktivitas harian anak secara terstruktur dengan penanda visual.'),
              _buildFeatureItem('SproutVoice', 'Prompting companion verbal real-time dan positive reinforcement berbasis suara yang ramah anak.'),
              _buildFeatureItem('SproutTrack', 'Behavior analytics untuk mencatat aktivitas, respon perilaku, dan visualisasi dashboard perkembangan.'),
              _buildFeatureItem('SproutLink', 'Media sinkronisasi dan kolaborasi riwayat aktivitas serta catatan langsung antara orang tua dan terapis.'),
              const SizedBox(height: 24),

              Text(
                'Dukungan SDGs',
                style: AppTextStyles.headingL.copyWith(color: AppColors.teal800),
              ),
              const SizedBox(height: 8),
              Text(
                'Sprout.ly mendukung Sustainable Development Goals (SDGs) khususnya SDG 3 (Good Health and Well-being) dan SDG 10 (Reduced Inequalities) melalui penyediaan layanan asistif cerdas yang inklusif, merata, dan mudah diakses bagi keluarga berkebutuhan khusus.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 48),
              Center(
                child: Text(
                  '© 2026 Tim PPL Gemastik Sproutly. All rights reserved.',
                  style: AppTextStyles.bodyS.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFC4806C), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.bodyM,
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
