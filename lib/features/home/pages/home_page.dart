import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';

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
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  const Text(
                    'Sedang dikerjakan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCurrentTaskCard(),
                  const SizedBox(height: 32),
                  const Text(
                    'Papan saya',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBoardGrid(),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Lihat semua',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        height: 1,
                        letterSpacing: 0.14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.peach500,
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.peach500,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Selamat pagi',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 2),
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
                ],
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral800.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.notifications_none, color: AppColors.neutral800.withOpacity(0.54)),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sikat gigi',
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
                  'Rutinitas Pagi',
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
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.play_arrow, color: AppColors.neutral800.withOpacity(0.54)),
          ),
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
      _BoardData('Kesal', AppColors.cream100),
      _BoardData('Rutinitas Pagi', AppColors.steel300),
      _BoardData('Menunggu 5 menit', AppColors.cream300),
      _BoardData('Menunggu 5 menit', AppColors.cream300),
      _BoardData('Rutinitas Pagi', AppColors.steel300),
      _BoardData('Kesal', AppColors.cream100),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: boardItems
          .map(
            (item) => _BoardCard(
              title: item.title,
              backgroundColor: item.backgroundColor,
            ),
          )
          .toList(),
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
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 152,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                height: 1.40,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

