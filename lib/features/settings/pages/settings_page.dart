import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _backgroundColor = AppColors.background;
  static const _sectionBackground = AppColors.teal100;
  static const _primaryActionColor = AppColors.peach500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 24),
                  _buildProfileCard(),
                  const SizedBox(height: 48),
                  _buildSection(
                    title: 'KARTU AKTIVITAS',
                    child: _buildCardAction(
                      title: 'Kelola aktivitas',
                      subtitle: 'Lihat dan edit kartu aktivitas',
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildSection(
                    title: 'AKSESIBILITAS',
                    child: _buildCardAction(
                      title: 'Pengaturan Aksesibilitas',
                      subtitle: 'Ukuran icon, ukuran text, animasi, dan suara',
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildSection(
                    title: 'AKUN',
                    child: _buildCardAction(
                      title: 'Keamanan Akun',
                      subtitle: 'Ubah email dan password',
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildAboutSection(),
                  const SizedBox(height: 48),
                  _buildLogoutCard(),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 144,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral800.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.settings, size: 48, color: AppColors.neutral800),
          SizedBox(width: 24),
          Text(
            'Pengaturan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 36,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              height: 1.17,
              letterSpacing: -0.72,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _sectionBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(48),
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.peach500,
              borderRadius: BorderRadius.circular(48),
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 6.46,
            height: 6.46,
            decoration: const BoxDecoration(
              color: AppColors.peach500,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    height: 1.20,
                    letterSpacing: -0.45,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ganti profil aktif',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.neutral800.withOpacity(0.54)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            height: 1.50,
            letterSpacing: 0.56,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildCardAction({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _sectionBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.settings, color: AppColors.neutral800.withOpacity(0.54)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.neutral800.withOpacity(0.54)),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TENTANG',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            height: 1.50,
            letterSpacing: 0.56,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _sectionBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              _buildAboutItem('Tentang Sprout.ly'),
              const SizedBox(height: 24),
              _buildAboutItem('Kebijakan Privasi'),
              const SizedBox(height: 24),
              _buildAboutItem('Ketentuan Layanan'),
              const SizedBox(height: 24),
              _buildAboutItem('Dukungan Pelanggan'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutItem(String title) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.info_outline, color: AppColors.neutral800.withOpacity(0.54)),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.neutral800.withOpacity(0.54)),
        ),
      ],
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primaryActionColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.logout, color: AppColors.peach500),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              'Keluar',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: -0.24,
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.peach500),
          ),
        ],
      ),
    );
  }
}
