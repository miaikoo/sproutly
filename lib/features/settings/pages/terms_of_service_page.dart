import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ketentuan Layanan', style: TextStyle(fontWeight: FontWeight.bold)),
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
                'Selamat datang di Sprout.ly. Dengan menggunakan aplikasi kami, Anda menyetujui ketentuan di bawah ini.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('1. Ruang Lingkup Layanan', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Sprout.ly adalah alat bantu intervensi visual berbasis AI di rumah untuk anak dengan ASD. Aplikasi ini bukan alat diagnosa medis resmi dan tidak bertujuan untuk menggantikan konsultasi medis, diagnosis, atau terapi klinis profesional.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('2. Tanggung Jawab Pengguna', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Sebagai orang tua, wali, atau terapis, Anda bertanggung jawab penuh atas pengawasan anak selama menjalankan rutinitas di rumah. Rekomendasi aktivitas dari AI (SproutGuide) bersifat suportif dan harus selalu Anda tinjau kembali kelayakannya.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('3. Batasan Tanggung Jawab', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Sprout.ly tidak bertanggung jawab atas kerugian fisik, tantrum, atau kejadian tidak terduga lainnya yang terjadi selama pelaksanaan rutinitas. Seluruh aktivitas dilakukan di bawah kendali dan pengawasan penuh dari pendamping.',
                style: AppTextStyles.bodyM,
              ),
              const SizedBox(height: 24),

              Text('4. Perubahan Ketentuan', style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                'Kami berhak memperbarui ketentuan layanan ini kapan saja. Perubahan akan segera diinfokan melalui pembaruan di halaman ini.',
                style: AppTextStyles.bodyM,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
