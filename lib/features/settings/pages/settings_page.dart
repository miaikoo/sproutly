import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_icon.dart'; 
import '../../../core/navigation/app_routes.dart';

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
                  _buildTitle(context),
                  const SizedBox(height: 24),
                  _buildProfileCard(context),
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    title: 'KARTU AKTIVITAS',
                    child: _buildCardAction(
                      iconAsset: 'assets/icons/solar_running-2-bold.svg', 
                      title: 'Kelola aktivitas',
                      subtitle: 'Lihat dan edit kartu aktivitas',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'AKSESIBILITAS',
                    child: _buildCardAction(
                      iconAsset: 'assets/icons/solar_accessibility-bold.svg', 
                      title: 'Pengaturan Aksesibilitas',
                      subtitle: 'Ukuran icon, ukuran text, animasi, dan suara',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'AKUN',
                    child: _buildCardAction(
                      iconAsset: 'assets/icons/solar_shield-keyhole-minimalistic-bold.svg', 
                      title: 'Keamanan Akun',
                      subtitle: 'Ubah email dan password',
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildAboutSection(),
                  const SizedBox(height: 48),
                  
                  _buildLogoutCard(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            'Pengaturan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
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

  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.profile); 
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _sectionBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.neutral300,
              child: ClipOval(
                child: SvgPicture.asset(
                  'assets/images/profile_pic.svg', 
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'John Doe',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.45,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ganti profil aktif',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const CustomIcon(
              assetName: 'assets/icons/solar_alt-arrow-right-outline.svg',
              size: 32,
              color: AppColors.neutral800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.56,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildCardAction({required String iconAsset, required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _sectionBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomIcon(
            assetName: iconAsset,
            size: 36,
            color: AppColors.neutral800,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const CustomIcon(
            assetName: 'assets/icons/solar_alt-arrow-right-outline.svg',
            size: 32,
            color: AppColors.neutral800,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'TENTANG',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.56,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _sectionBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildAboutItem('assets/icons/ix_about.svg', 'Tentang Sprout.ly'),
              Divider(height: 1, color: AppColors.neutral800.withOpacity(0.15), indent: 16, endIndent: 16),
              _buildAboutItem('assets/icons/material-symbols_privacy-tip-outline-rounded.svg', 'Kebijakan Privasi'),
              Divider(height: 1, color: AppColors.neutral800.withOpacity(0.15), indent: 16, endIndent: 16),
              _buildAboutItem('assets/icons/material-symbols_text-snippet-outline-rounded.svg', 'Ketentuan Layanan'),
              Divider(height: 1, color: AppColors.neutral800.withOpacity(0.15), indent: 16, endIndent: 16),
              _buildAboutItem('assets/icons/material-symbols_support.svg', 'Dukungan Pelanggan'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutItem(String iconAsset, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CustomIcon(
            assetName: iconAsset,
            size: 32,
            color: AppColors.neutral800,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const CustomIcon(
            assetName: 'assets/icons/solar_alt-arrow-right-outline.svg',
            size: 28,
            color: AppColors.neutral800,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryActionColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomIcon(
            assetName: 'assets/icons/solar_exit-outline.svg',
            size: 32,
            color: AppColors.white,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const CustomIcon(
            assetName: 'assets/icons/solar_alt-arrow-right-outline.svg',
            size: 32,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}