import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/activity_image.dart';
import '../../../shared/widgets/page_header.dart';

/// The board types a parent can start from, with the route each one opens.
const _options = [
  (
    title: 'Aktivitas',
    image: 'assets/images/Belajar.png',
    route: AppRoutes.createBoardActivity,
  ),
  (
    title: 'Menunggu',
    image: 'assets/images/Menunggu.png',
    route: AppRoutes.createWaitingBoard,
  ),
  (
    title: 'Emosi',
    image: 'assets/images/Bahagia.png',
    route: AppRoutes.createEmotionBoard,
  ),
];

class CreateBoardPage extends StatefulWidget {
  const CreateBoardPage({super.key});

  @override
  State<CreateBoardPage> createState() => _CreateBoardPageState();
}

class _CreateBoardPageState extends State<CreateBoardPage> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                const PageHeader(title: 'Buat Papan Baru'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        AppSpacing.gapMD,
                        Text(
                          'Papan apa yang ingin kamu buat?',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayM,
                        ),
                        AppSpacing.gapXXL,
                        for (final option in _options) ...[
                          _OptionCard(
                            title: option.title,
                            image: option.image,
                            selected: _selected == option.title,
                            onTap: () => setState(() => _selected = option.title),
                          ),
                          AppSpacing.gapMD,
                        ],
                      ],
                    ),
                  ),
                ),
                // Pinned to the bottom as in the design, so the choice and the
                // confirmation never scroll apart.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.peach500,
                        // The design's own disabled treatment: a paler fill of
                        // the same hue. WCAG exempts disabled controls from the
                        // contrast minimum, so this one is faithful as drawn.
                        disabledBackgroundColor: AppColors.peach200,
                        disabledForegroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.pill),
                        ),
                      ),
                      onPressed: _selected == null ? null : _next,
                      child: const Text('Selanjutnya'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _next() {
    final option = _options.firstWhere((o) => o.title == _selected);
    context.push(option.route);
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      label: title,
      child: Material(
        color: AppColors.teal100,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(
                color: selected ? AppColors.teal700 : AppColors.teal200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: ActivityImage(image),
                ),
                AppSpacing.gapHLG,
                Expanded(child: Text(title, style: AppTextStyles.headingL)),
                _Radio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.peach500, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.peach500,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
