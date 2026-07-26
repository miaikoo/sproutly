import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
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
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildMapArea(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          // Badge Point & Shopping Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal500,
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
                  color: AppColors.peach500,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Stepping stones coordinates 
        final nodes = [
          const Offset(0.35, 0.05),
          const Offset(0.75, 0.25),
          const Offset(0.15, 0.45),
          const Offset(0.50, 0.65),
          const Offset(0.75, 0.85),
        ];

        return Stack(
          children: [
            CustomPaint(
              size: Size(w, h),
              painter: _DashedPathPainter(nodes),
            ),
            
            ...nodes.asMap().entries.map((e) {
              final isFirst = e.key == 0;
              return Positioned(
                left: e.value.dx * w - 45,
                top: e.value.dy * h - 35, 
                child: _buildNode(isFirst: isFirst),
              );
            }).toList(),

            // Companion
            Positioned(
              left: nodes.last.dx * w - 60, 
              top: nodes.last.dy * h - 140, 
              child: Image.asset(
                'assets/images/happy.png',
                width: 240,
                height: 300, 
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      }
    );
  }

  // Desain Batu Pijakan 3D Oval
  Widget _buildNode({bool isFirst = false}) {
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(
        color: isFirst ? const Color(0xFFF1F5F4) : const Color(0xFFB8D2CE),
        borderRadius: BorderRadius.circular(45), 
        border: Border.all(
          color: isFirst ? AppColors.neutral300 : const Color(0xFF7EA29C),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: isFirst ? AppColors.neutral300 : const Color(0xFF7EA29C),
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}

// Dashed path
class _DashedPathPainter extends CustomPainter {
  final List<Offset> nodes;
  _DashedPathPainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFC4806C).withOpacity(0.8) // Path color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(nodes[0].dx * size.width, nodes[0].dy * size.height);
    
    for (int i = 0; i < nodes.length - 1; i++) {
      final p0 = Offset(nodes[i].dx * size.width, nodes[i].dy * size.height);
      final p1 = Offset(nodes[i+1].dx * size.width, nodes[i+1].dy * size.height);
      
      final cx = (p0.dx + p1.dx) / 2;
      final cy = p0.dy; // Control point for the curve

      path.quadraticBezierTo(cx, cy, p1.dx, p1.dy);
    }

    // Draw dashed path
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final dashPath = pathMetric.extractPath(distance, distance + 12); 
        canvas.drawPath(dashPath, paint);
        distance += 24; 
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}