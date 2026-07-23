import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  AppSpacing.gapXXL,
                  _buildProfileCard(
                    name: 'John Doe',
                    subtitle: 'Profil aktif',
                    accentColor: AppColors.peach500,
                    avatarColor: AppColors.neutral300,
                    dotColor: AppColors.peach500,
                    backgroundColor: AppColors.teal100,
                    borderColor: AppColors.neutral800.withOpacity(0.2),
                  ),
                  AppSpacing.gapXXL,
                  _buildProfileCard(
                    name: 'Jane Doe',
                    subtitle: null,
                    accentColor: AppColors.steel300,
                    avatarColor: AppColors.neutral300,
                    dotColor: AppColors.steel300,
                    backgroundColor: AppColors.teal100,
                    borderColor: AppColors.neutral800.withOpacity(0.2),
                    showIndicator: true,
                    indicatorBorderColor: AppColors.peach500,
                  ),
                  AppSpacing.gapXXL,
                  _buildAddProfileCard(),
                  AppSpacing.gapXXXL,
                  _buildPageHandle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral800.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: AppColors.textPrimary),
        ),
        AppSpacing.gapHXL,
        Text('Profil', style: AppTextStyles.displayL),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral800.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.more_vert, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildProfileCard({
    required String name,
    String? subtitle,
    required Color accentColor,
    required Color avatarColor,
    required Color dotColor,
    required Color backgroundColor,
    required Color borderColor,
    bool showIndicator = false,
    Color indicatorBorderColor = AppColors.peach500,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          _buildAvatar(avatarColor),
          AppSpacing.gapHXL,
          _buildAccentAvatar(accentColor),
          AppSpacing.gapHXL,
          _buildStatusDot(dotColor),
          AppSpacing.gapHXL,
          SizedBox(
            width: 127,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.displayL),
                if (subtitle != null) ...[
                  AppSpacing.gapXS,
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyL.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showIndicator) ...[
            const Spacer(),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: indicatorBorderColor, width: 4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(48),
      ),
    );
  }

  Widget _buildAccentAvatar(Color color) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(48),
      ),
    );
  }

  Widget _buildStatusDot(Color color) {
    return Container(
      width: 6.46,
      height: 6.46,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildAddProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.peach100,
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.peach500, width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: AppColors.textPrimary),
          ),
          AppSpacing.gapHSM,
          Expanded(
            child: Text(
              'Tambah Profil Baru',
              style: AppTextStyles.headingL.copyWith(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHandle() {
    return Center(
      child: Container(
        width: 144,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutral800.withOpacity(0.6),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
