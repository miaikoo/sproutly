import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/activity_catalog.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/custom_icon.dart';
import 'board_editor.dart';
import '../../../shared/widgets/activity_image.dart';
import '../../../core/theme/app_text_styles.dart';

/// Category chips offered when making an activity, mapped to the enum actually
/// stored. Labels without a matching category were dropped rather than saved as
/// something else.
final _sectionLabel = AppTextStyles.headingS;

const _categoryOptions = <String, ActivityCategory>{
  'Perawatan diri': ActivityCategory.selfCare,
  'Makan': ActivityCategory.meal,
  'Belajar': ActivityCategory.study,
  'Bermain': ActivityCategory.play,
  'Istirahat': ActivityCategory.bedtime,
  'Terapi': ActivityCategory.therapy,
  'Menunggu': ActivityCategory.waiting,
  'Emosi': ActivityCategory.emotion,
  'Lainnya': ActivityCategory.other,
};

class CreateActivityPage extends ConsumerStatefulWidget {
  const CreateActivityPage({super.key});

  @override
  ConsumerState<CreateActivityPage> createState() => _CreateActivityPageState();
}

class _CreateActivityPageState extends ConsumerState<CreateActivityPage> {
  String _title = '';
  String _image = ActivityCatalog.items.first.image;
  ActivityCategory _category = ActivityCategory.selfCare;
  final List<String> _steps = [];
  bool _isSaving = false;
  bool _isUploading = false;

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
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleCard(),
                        const SizedBox(height: 24),
                        _buildImagePicker(),
                        const SizedBox(height: 32),
                        Text('KATEGORI', style: _sectionLabel),
                        const SizedBox(height: 12),
                        _buildCategoryChips(),
                        const SizedBox(height: 32),
                        _buildStepsSection(),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const CustomIcon(
              assetName: 'assets/icons/solar_alt-arrow-left-outline.svg',
              size: 28,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Buat Aktivitas',
            style: AppTextStyles.displayL,
          ),
          const Spacer(),
          GestureDetector(
            onTap: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const CustomIcon(
                    assetName: 'assets/icons/lucide_save.svg',
                    size: 28,
                    color: AppColors.neutral800,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return GestureDetector(
      onTap: _editTitle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.steel100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _title.isEmpty ? 'Beri nama aktivitas' : _title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.displayM,
              ),
            ),
            const CustomIcon(
              assetName: 'assets/icons/solar_pen-linear.svg',
              size: 24,
              color: AppColors.neutral800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ActivityImage(_image),
          ),
        ),
        const SizedBox(height: 24),
        // A photo of the child's own bathroom or plate is far more meaningful to
        // them than a generic pictogram, so uploading is offered alongside the
        // bundled artwork.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            _chip('Gambar Bawaan', _pickImage),
            _chip('Ambil Foto', () => _upload(ImageSource.camera)),
            _chip('Dari Galeri', () => _upload(ImageSource.gallery)),
          ],
        ),
        if (_isUploading) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isUploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.teal700,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Text(
          label,
          style: AppTextStyles.headingS.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categoryOptions.entries.map((entry) {
        final isSelected = _category == entry.value;
        return GestureDetector(
          onTap: () => setState(() => _category = entry.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.teal700 : AppColors.teal500,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Text(
              entry.key,
              style: AppTextStyles.bodyM.copyWith(color: AppColors.white),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Instructions SproutVoice reads out one at a time during a guided run.
  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('INSTRUKSI BERTAHAP', style: _sectionLabel),
            TextButton(onPressed: _addStep, child: Text('+ Tambah')),
          ],
        ),
        const SizedBox(height: 8),
        if (_steps.isEmpty)
          Text(
            'Opsional. Tanpa instruksi, SproutVoice hanya menyebut nama aktivitas.',
            style: AppTextStyles.bodyM,
          )
        else
          for (var i = 0; i < _steps.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.teal500,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                ),
              ),
              title: Text(_steps[i]),
              trailing: IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _steps.removeAt(i)),
              ),
            ),
      ],
    );
  }

  Future<void> _addStep() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Langkah ${_steps.length + 1}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Contoh: Ambil kotak mainan.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Tambah'),
          ),
        ],
      ),
    );
    final trimmed = result?.trim();
    if (trimmed != null && trimmed.isNotEmpty) setState(() => _steps.add(trimmed));
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nama Aktivitas'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Contoh: Merapikan mainan'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
    final trimmed = result?.trim();
    if (trimmed != null && trimmed.isNotEmpty) setState(() => _title = trimmed);
  }

  /// Uploads a photo and points the card at it. The child profile must exist
  /// first, since the storage path is scoped per child.
  Future<void> _upload(ImageSource source) async {
    setState(() => _isUploading = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      final url = await ref.read(imageUploadServiceProvider).pickAndUpload(
            childId: child.id,
            source: source,
            folder: 'activities',
          );
      // null means the parent closed the picker — not an error.
      if (url != null && mounted) setState(() => _image = url);
    } catch (e) {
      if (mounted) showBoardSnack(context, 'Gagal mengunggah gambar: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    final images = ActivityCatalog.availableImages;
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Gambar'),
        content: SizedBox(
          width: 360,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: images
                .map((path) => GestureDetector(
                      onTap: () => Navigator.pop(context, path),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(12),
                          border: path == _image
                              ? Border.all(color: AppColors.teal700, width: 3)
                              : null,
                        ),
                        child: ActivityImage(path),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _save() async {
    if (_title.isEmpty) {
      showBoardSnack(context, 'Beri nama aktivitas sebelum menyimpan.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final child = await ref.read(currentChildProvider.future);
      if (child == null) throw StateError('Profil anak belum tersedia.');

      final item = ActivityCatalogItem(
        // Prefixed so a parent-made card can never collide with a preset id.
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        title: _title,
        image: _image,
        category: _category,
        steps: List.of(_steps),
      );
      await ref.read(childServiceProvider).addCustomActivity(child.id, item);

      if (mounted) {
        showBoardSnack(context, '${item.title} ditambahkan ke daftar aktivitas.');
        context.pop();
      }
    } catch (e) {
      if (mounted) showBoardSnack(context, 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
