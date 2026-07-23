import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _backgroundColor = AppColors.background;
  static const _cardBackground = AppColors.teal100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(context), 
                  const SizedBox(height: 24),
                  const Text(
                    'Sedang dikerjakan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCurrentTaskCard(),
                  const SizedBox(height: 32),
                  const Text(
                    'Papan saya',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBoardGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Avatar profile picture
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.neutral300,
              child: ClipOval(
                child: SvgPicture.asset(
                  'assets/images/profile_pic.svg',
                  width: 64, 
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Selamat pagi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                  ),
                ),
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
              ],
            ),
          ],
        ),
        // Settings Routing
        GestureDetector(
          onTap: () {
            context.push(AppRoutes.settings);
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.transparent, 
            ),
            child: const Icon(
              Icons.settings, 
              color: AppColors.neutral800,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80, 
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sikat gigi',
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
                  'Rutinitas Pagi',
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
          const SizedBox(width: 8),
          // Arrow chevron_right (mengikuti figma)
          const Icon(Icons.chevron_right, color: AppColors.neutral800, size: 32),
        ],
      ),
    );
  }

  Widget _buildBoardGrid() {
    final boardItems = [
      _BoardData('Rutinitas Pagi', AppColors.steel300),
      _BoardData('Kesal', AppColors.cream100),
      _BoardData('Menunggu 5 menit', AppColors.cream300),
      _BoardData('Kesal', AppColors.cream100),
      _BoardData('Menunggu 5 menit', AppColors.cream300),
      _BoardData('Rutinitas Pagi', AppColors.steel300),
    ];

    // Grid view
    return GridView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 16,
        mainAxisSpacing: 16, 
        childAspectRatio: 0.80,
      ),
      itemCount: boardItems.length,
      itemBuilder: (context, index) {
        final item = boardItems[index];
        return _BoardCard(
          title: item.title,
          backgroundColor: item.backgroundColor,
        );
      },
    );
  }
}

class Home extends HomePage {
  const Home({super.key});
}

class _BoardData {
  const _BoardData(this.title, this.backgroundColor);
  final String title;
  final Color backgroundColor;
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.title, required this.backgroundColor});

  final String title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            // Content placeholder
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Text
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}