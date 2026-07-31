import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/activity_catalog.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/activity_image.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/page_header.dart';

class ManageActivitiesPage extends ConsumerStatefulWidget {
  const ManageActivitiesPage({super.key});

  @override
  ConsumerState<ManageActivitiesPage> createState() => _ManageActivitiesPageState();
}

class _ManageActivitiesPageState extends ConsumerState<ManageActivitiesPage> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(currentChildProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                PageHeader(
                  title: 'Kelola Aktivitas',
                  actions: [
                    IconButton(
                      onPressed: () => context.push(AppRoutes.createActivity),
                      icon: const Icon(Icons.add, size: 28),
                      color: AppColors.peach500,
                      tooltip: 'Tambah aktivitas',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Cari aktivitas kustom...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.neutral600),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.neutral600),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.teal100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text('Gagal memuat aktivitas: $e', style: AppTextStyles.bodyM),
                    ),
                    data: (child) {
                      if (child == null) {
                        return Center(
                          child: Text('Profil anak tidak ditemukan.', style: AppTextStyles.bodyM),
                        );
                      }

                      final allCustom = child.customActivities;
                      final filtered = allCustom.where((item) {
                        return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (allCustom.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Tidak ada aktivitas yang cocok dengan "$_searchQuery"',
                              style: AppTextStyles.bodyM,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildActivityCard(context, child.id, item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomIcon(
              assetName: 'assets/icons/solar_running-2-bold.svg',
              size: 80,
              color: AppColors.teal300,
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Aktivitas Kustom',
              style: AppTextStyles.displayM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Buat kartu aktivitas khusus untuk mempermudah rutinitas harian anak Anda.',
              style: AppTextStyles.bodyM,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.createActivity),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.peach500,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              icon: const Icon(Icons.add, color: AppColors.white),
              label: Text(
                'Buat Aktivitas',
                style: AppTextStyles.headingM.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String childId, ActivityCatalogItem item) {
    final stepCount = item.steps.length;
    final categoryName = _getCategoryLabel(item.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ActivityImage(item.image),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.headingL,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.teal700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        categoryName,
                        style: AppTextStyles.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stepCount > 0 ? '$stepCount Langkah' : 'Tanpa Langkah',
                      style: AppTextStyles.bodyS,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.createActivity, extra: item),
            icon: const CustomIcon(
              assetName: 'assets/icons/solar_pen-linear.svg',
              size: 24,
              color: AppColors.neutral800,
            ),
            tooltip: 'Edit aktivitas',
          ),
          IconButton(
            onPressed: () => _confirmRemove(context, childId, item),
            icon: const Icon(Icons.delete_outline, color: AppColors.peach500, size: 24),
            tooltip: 'Hapus aktivitas',
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.morningRoutine:
        return 'Rutinitas Pagi';
      case ActivityCategory.selfCare:
        return 'Perawatan Diri';
      case ActivityCategory.meal:
        return 'Makan';
      case ActivityCategory.study:
        return 'Belajar';
      case ActivityCategory.play:
        return 'Bermain';
      case ActivityCategory.exercise:
        return 'Olahraga';
      case ActivityCategory.bedtime:
        return 'Istirahat';
      case ActivityCategory.therapy:
        return 'Terapi';
      case ActivityCategory.waiting:
        return 'Menunggu';
      case ActivityCategory.emotion:
        return 'Emosi';
      case ActivityCategory.other:
        return 'Lainnya';
    }
  }

  Future<void> _confirmRemove(BuildContext context, String childId, ActivityCatalogItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${item.title}?'),
        content: const Text(
          'Aktivitas ini tidak lagi bisa dipilih. Papan yang sudah memakainya tetap utuh.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(childServiceProvider).removeCustomActivity(childId, item);
    if (isUploadedImage(item.image)) {
      await ref.read(imageUploadServiceProvider).deleteByUrl(item.image);
    }

    messenger.showSnackBar(
      SnackBar(content: Text('${item.title} berhasil dihapus')),
    );
  }
}
