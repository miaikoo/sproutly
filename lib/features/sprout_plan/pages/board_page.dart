import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final items = List.generate(
      12,
      (i) => _BoardData(
        title: i % 3 == 0 ? 'Rutinitas Pagi' : (i % 3 == 1 ? 'Kesal' : 'Menunggu 5 menit'),
        background: i % 3 == 0
            ? AppColors.steel300
            : (i % 3 == 1 ? AppColors.cream100 : AppColors.cream300),
      ),
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
  const _BoardData({required this.title, required this.background});
  final String title;
  final Color background;
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: data.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.title,
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