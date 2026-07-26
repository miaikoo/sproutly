import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

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
            child: Image.asset(
              'assets/images/Sikat Gigi.png',
              fit: BoxFit.contain,
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
    const activities = [
      (title: 'Belajar', image: 'assets/images/Belajar.png', type: 'aktivitas'),
      (title: 'Bermain', image: 'assets/images/Bermain.png', type: 'aktivitas'),
      (title: 'Makan', image: 'assets/images/Makan.png', type: 'aktivitas'),
      (title: 'Mandi', image: 'assets/images/Mandi.png', type: 'aktivitas'),
      (title: 'Memakai baju', image: 'assets/images/Memakai baju.png', type: 'aktivitas'),
      (title: 'Memakai sepatu', image: 'assets/images/Memakai sepatu.png', type: 'aktivitas'),
      (title: 'Sikat Gigi', image: 'assets/images/Sikat Gigi.png', type: 'aktivitas'),
      (title: 'Terapi', image: 'assets/images/Terapi.png', type: 'aktivitas'),
      (title: 'Tidur', image: 'assets/images/Tidur.png', type: 'aktivitas'),
      (title: 'Menunggu', image: 'assets/images/Menunggu.png', type: 'menunggu'),
      (title: 'Bahagia', image: 'assets/images/Bahagia.png', type: 'emosi'),
      (title: 'Berpikir', image: 'assets/images/Berpikir.png', type: 'emosi'),
      (title: 'Ceria', image: 'assets/images/Ceria.png', type: 'emosi'),
      (title: 'Kesal', image: 'assets/images/Kesal.png', type: 'emosi'),
      (title: 'Sedih', image: 'assets/images/Sedih.png', type: 'emosi'),
      (title: 'Semangat', image: 'assets/images/Semangat.png', type: 'emosi'),
      (title: 'Tenang', image: 'assets/images/Tenang.png', type: 'emosi'),
    ];
    
    Color getColorByType(String type) {
      switch (type) {
        case 'aktivitas':
          return const Color(0xFFBCA0B0); // Pink
        case 'menunggu':
          return const Color(0xFFDDD1A4); // Yellow
        case 'emosi':
          return const Color(0xFF98B6CE); // Blue
        default:
          return const Color(0xFF98B6CE);
      }
    }
    
    final random = Random();
    final boardItems = [
      () {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(activity.title, getColorByType(activity.type), activity.image);
      }(),
      () {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(activity.title, getColorByType(activity.type), activity.image);
      }(),
      () {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(activity.title, getColorByType(activity.type), activity.image);
      }(),
      () {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(activity.title, getColorByType(activity.type), activity.image);
      }(),
      () {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(activity.title, getColorByType(activity.type), activity.image);
      }(),
      () {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(activity.title, getColorByType(activity.type), activity.image);
      }(),
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
          imagePath: item.imagePath,
        );
      },
    );
  }
}

class Home extends HomePage {
  const Home({super.key});
}

class _BoardData {
  _BoardData(this.title, this.backgroundColor, this.imagePath);
  final String title;
  final Color backgroundColor;
  final String imagePath;
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({
    required this.title,
    required this.backgroundColor,
    required this.imagePath,
  });

  final String title;
  final Color backgroundColor;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Text
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}