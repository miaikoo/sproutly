import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_icon.dart';

class BuddyPage extends StatelessWidget {
  const BuddyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Stack(
              children: [
                _buildMapArea(),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background.withOpacity(0.8), 
            AppColors.background.withOpacity(0.0), 
          ],
          stops: const [0.3, 0.7, 1.0], 
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'John Doe',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Perjalanan sejak 16/07/2026',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7EA29C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: const [
                    CustomIcon(
                      assetName: 'assets/icons/glyphs_coin-bold.svg', 
                      size: 20,
                      color: AppColors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '28',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFC4806C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const CustomIcon(
                  assetName: 'assets/icons/solar_shop-2-bold.svg', 
                  size: 24,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return ListView.builder(
      reverse: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildMapChunk(context, chunkIndex: index);
      },
    );
  }

  Widget _buildMapChunk(BuildContext context, {required int chunkIndex}) {
    // AscpectRatio 10:16 
    return AspectRatio(
      aspectRatio: 10 / 16, 
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Coordinate Percentage
          final nodes = [
            const Offset(0.65, 0.85),
            const Offset(0.18, 0.60),
            const Offset(0.78, 0.35),
            const Offset(0.20, 0.10),
          ];

          return Stack(
            children: [
              // Layer 1 - Background 
              Positioned.fill(
                child: Image.asset(
                  'assets/images/buddy_background.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Layer 2 - Stepping Stones
              ...nodes.asMap().entries.map((e) {
                final isActive = chunkIndex == 0 && e.key == 0;
                
                return Positioned(
                  left: e.value.dx * w - 45,
                  top: e.value.dy * h - 30, 
                  child: _buildNode(isActive: isActive),
                );
              }).toList(),

              // Layer 3 - Companion
              if (chunkIndex == 0)
                Positioned(
                  left: nodes[0].dx * w - 100,
                  top: nodes[0].dy * h - 220, 
                  child: Image.asset(
                    'assets/images/Bahagia.png',
                    width: 200,  
                    height: 250, 
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  // Widget Stepping Stone
  Widget _buildNode({bool isActive = false}) {
    return Container(
      width: 100, 
      height: 70,
      decoration: ShapeDecoration(
        color: isActive ? const Color(0xFFF1F5F4) : const Color(0xFFB8D2CE),
        shape: OvalBorder(
          side: BorderSide(
            color: isActive ? AppColors.neutral300 : const Color(0xFF7EA29C),
            width: 3,
          ),
        ),
        shadows: [
          BoxShadow(
            color: isActive ? AppColors.neutral300 : const Color(0xFF7EA29C),
            offset: const Offset(0, 8),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }
}