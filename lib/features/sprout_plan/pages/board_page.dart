import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_icon.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
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
    final items = List.generate(
      12,
      (i) {
        final activity = activities[random.nextInt(activities.length)];
        return _BoardData(
          title: activity.title,
          background: getColorByType(activity.type),
          imagePath: activity.image,
        );
      },
    );

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
                  _buildHeader(context),
                  AppSpacing.gapMD,
                  _buildFilterChips(),
                  AppSpacing.gapXL,
                  _buildBoardGrid(items),
                  AppSpacing.gapXXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Papan saya', style: AppTextStyles.displayXL),
          GestureDetector(
            onTap: () => context.push(AppRoutes.createBoard),
            child: const CustomIcon(
              assetName: 'assets/icons/solar_clipboard-add-outline.svg',
              size: 32,
              color: AppColors.peach500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Aktivitas', 'Menunggu', 'Emosi'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((label) {
          final isSelected = _selectedFilter == label;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = label),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF446860) : const Color(0xFF7EA29C),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBoardGrid(List<_BoardData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _BoardCard(data: items[index]);
      },
    );
  }
}

class _BoardData {
  _BoardData({required this.title, required this.background, required this.imagePath});
  final String title;
  final Color background;
  final String imagePath;
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.data});
  final _BoardData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(24), 
            ),
            child: Image.asset(
              data.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16), 
        Text(
          data.title,
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