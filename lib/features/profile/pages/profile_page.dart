import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/custom_icon.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock state 
  String _activeProfile = 'John Doe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 32),
                  
                  // Card Profile 1
                  _buildProfileCard(
                    name: 'John Doe',
                    isActive: _activeProfile == 'John Doe',
                    onTap: () {
                      setState(() {
                        _activeProfile = 'John Doe';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Card Profile 2
                  _buildProfileCard(
                    name: 'Jane Doe',
                    isActive: _activeProfile == 'Jane Doe',
                    onTap: () {
                      setState(() {
                        _activeProfile = 'Jane Doe';
                      });
                    },
                  ),
                  const SizedBox(height: 48),
                  
                  _buildAddProfileCard(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(), // Back button function
                child: const CustomIcon(
                  assetName: 'assets/icons/solar_alt-arrow-left-outline.svg',
                  size: 28,
                  color: AppColors.neutral800,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Profil',
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
          const CustomIcon(
            assetName: 'assets/icons/solar_clipboard-add-outline.svg',
            size: 28,
            color: AppColors.peach500,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required String name,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.teal100,
          borderRadius: BorderRadius.all(AppRadius.lg),
          border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
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
            
            // Text Detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.45,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Profil aktif',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            // Indicator Radio/Checkmark
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.peach500 : Colors.transparent,
                border: isActive 
                    ? null 
                    : Border.all(color: AppColors.peach500, width: 2),
              ),
              child: isActive 
                  ? const Icon(Icons.check, color: AppColors.white, size: 20) 
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3EF),
        borderRadius: BorderRadius.all(AppRadius.lg),
        border: Border.all(color: AppColors.peach500, width: 2)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.peach500, width: 2),
            ),
            child: const Icon(Icons.add, color: AppColors.peach500, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tambah Profil Baru',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}