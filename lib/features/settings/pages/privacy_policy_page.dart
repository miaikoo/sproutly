import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi', style: TextStyle(fontWeight: FontWeight.bold)),
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
                'Terakhir Diperbarui: 31 Juli 2026',
                style: AppTextStyles.bodyS.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                'Kami di Sprout.ly berkomitmen penuh untuk melindungi privasi keluarga Anda, terutama data sensitif anak Anda.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('1. Informasi yang Kami Kumpulkan', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                '- Informasi Akun: Nama orang tua/terapis, alamat email, dan password.\n'
                '- Profil Anak: Nama anak, tanggal lahir, tingkat perkembangan, dan foto profil.\n'
                '- Data Aktivitas & Perilaku: Log rutinitas harian anak, durasi, respon emosi, dan catatan perkembangan.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('2. Penggunaan Data', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Seluruh data anak Anda digunakan murni untuk mempersonalisasi visual schedule, memberikan voice prompting companion, menyusun grafik analytics di dashboard, serta sinkronisasi data kolaborasi bersama terapis.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('3. Keamanan Data', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Kami menggunakan enkripsi standar industri saat pengiriman dan penyimpanan data di cloud. Data Anda tidak akan pernah dijual atau dibagikan kepada pihak ketiga tanpa persetujuan eksplisit Anda.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('4. Kendali Anda', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Anda memiliki hak penuh untuk mengakses, mengubah, atau menghapus profil anak Anda secara langsung di dalam aplikasi kapan saja.',
                style: AppTextStyles.bodyM,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
