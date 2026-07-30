import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/data/activity_catalog.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/image_upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../models/child.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/custom_icon.dart';
import '../../../shared/widgets/activity_image.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../core/theme/app_spacing.dart';

const _severityLabels = {
  Severity.mild: 'Ringan',
  Severity.moderate: 'Sedang',
  Severity.severe: 'Berat',
};

final _body = AppTextStyles.bodyM;
final _sectionLabel = AppTextStyles.headingS;

/// Full profile for one child (RF-02): characteristics, preferences,
/// intervention targets, photo, and the parent's own activity cards.
class ChildProfilePage extends ConsumerWidget {
  const ChildProfilePage({super.key, required this.childId});

  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(childByIdProvider(childId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                const PageHeader(title: 'Profil Anak'),
                Expanded(
                  child: childAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text('Gagal memuat profil anak: $e', style: _body),
                    ),
                    data: (child) => child == null
                        ? Center(child: Text('Profil tidak ditemukan.', style: _body))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl,
                              AppSpacing.md,
                              AppSpacing.xl,
                              AppSpacing.huge,
                            ),
                            child: _ProfileBody(child: child),
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
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.child});

  final Child child;

  ChildService _service(WidgetRef ref) => ref.read(childServiceProvider);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerCard(context, ref),
        const SizedBox(height: 32),

        Text('KARAKTERISTIK', style: _sectionLabel),
        const SizedBox(height: 12),
        _row(
          label: 'Tanggal lahir',
          value: DateFormat('d MMMM y').format(child.birthDate),
          onTap: () => _editBirthDate(context, ref),
        ),
        _row(
          label: 'Tingkat perkembangan',
          value: _severityLabels[child.severity] ?? child.severity.name,
          onTap: () => _editSeverity(context, ref),
        ),
        const SizedBox(height: 32),

        _EditableTags(
          label: 'PREFERENSI',
          hint: 'Hal yang disukai anak, misalnya musik atau stiker.',
          values: child.preferences,
          onChanged: (values) => _service(ref).updateProfile(child.id, preferences: values),
        ),
        const SizedBox(height: 32),

        _EditableTags(
          label: 'TARGET INTERVENSI',
          hint: 'Kemampuan yang sedang dilatih, misalnya makan mandiri.',
          values: child.interventionTargets,
          onChanged: (values) =>
              _service(ref).updateProfile(child.id, interventionTargets: values),
        ),
        const SizedBox(height: 32),

        _customActivitiesSection(context, ref),
      ],
    );
  }

  Widget _headerCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _editName(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.teal100,
          borderRadius: const BorderRadius.all(AppRadius.lg),
          border: Border.all(color: AppColors.neutral800.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _changePhoto(context, ref),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.neutral300,
                    child: ClipOval(
                      child: child.photoUrl.isEmpty
                          ? SvgPicture.asset(
                              'assets/images/profile_pic.svg',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              child.photoUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => SvgPicture.asset(
                                'assets/images/profile_pic.svg',
                                width: 72,
                                height: 72,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.peach500,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_camera,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.displayM,
                  ),
                  const SizedBox(height: 4),
                  Text('${child.ageInYears(DateTime.now())} tahun', style: _body),
                ],
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

  Widget _row({required String label, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.headingL,
              ),
            ),
            Text(value, style: _body),
            const SizedBox(width: 8),
            const CustomIcon(
              assetName: 'assets/icons/solar_alt-arrow-right-outline.svg',
              size: 24,
              color: AppColors.neutral800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _customActivitiesSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AKTIVITAS BUATAN SENDIRI', style: _sectionLabel),
        const SizedBox(height: 12),
        if (child.customActivities.isEmpty)
          Text(
            'Belum ada. Buat lewat "Buat Baru" saat menambahkan aktivitas ke papan.',
            style: _body,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: child.customActivities
                .map((item) => Chip(
                      avatar: ActivityImage(item.image),
                      label: Text(item.title),
                      onDeleted: () => _confirmRemove(context, ref, item),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    ActivityCatalogItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus ${item.title}?'),
        content: Text(
          'Aktivitas ini tidak lagi bisa dipilih. Papan yang sudah memakainya tetap utuh.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;

    await _service(ref).removeCustomActivity(child.id, item);
    // Drop the uploaded photo too, otherwise deleting the card leaves the file
    // behind in Storage forever. Bundled assets have nothing to clean up.
    if (isUploadedImage(item.image)) {
      await ref.read(imageUploadServiceProvider).deleteByUrl(item.image);
    }
  }

  /// Replaces the child's photo. The old file is deleted afterwards so a parent
  /// swapping photos a few times doesn't leave orphans in Storage.
  Future<void> _changePhoto(BuildContext context, WidgetRef ref) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Foto Anak'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text('Ambil foto'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text('Pilih dari galeri'),
          ),
        ],
      ),
    );
    if (source == null) return;

    final uploader = ref.read(imageUploadServiceProvider);
    try {
      final url = await uploader.pickAndUpload(
        childId: child.id,
        source: source,
        folder: 'profile',
      );
      if (url == null) return; // Parent closed the picker.

      final previous = child.photoUrl;
      await _service(ref).updateProfile(child.id, photoUrl: url);
      if (previous.isNotEmpty) await uploader.deleteByUrl(previous);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $e')));
      }
    }
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: child.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nama Anak'),
        content: TextField(controller: controller, autofocus: true),
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
    if (trimmed != null && trimmed.isNotEmpty) {
      await _service(ref).updateProfile(child.id, name: trimmed);
    }
  }

  Future<void> _editBirthDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: child.birthDate,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      await _service(ref).updateProfile(child.id, birthDate: picked);
    }
  }

  Future<void> _editSeverity(BuildContext context, WidgetRef ref) async {
    final picked = await showDialog<Severity>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Tingkat Perkembangan'),
        children: _severityLabels.entries
            .map((entry) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, entry.key),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontWeight:
                          entry.key == child.severity ? FontWeight.w800 : FontWeight.w400,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
    if (picked != null) {
      await _service(ref).updateProfile(child.id, severity: picked);
    }
  }
}

/// A labelled list of short free-text entries the parent can add to or remove.
class _EditableTags extends StatelessWidget {
  const _EditableTags({
    required this.label,
    required this.hint,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  Future<void> _add(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
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
    // Duplicates would just clutter the AI prompt.
    if (trimmed == null || trimmed.isEmpty || values.contains(trimmed)) return;
    onChanged([...values, trimmed]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _sectionLabel),
            TextButton(onPressed: () => _add(context), child: Text('+ Tambah')),
          ],
        ),
        const SizedBox(height: 8),
        if (values.isEmpty)
          Text(hint, style: _body)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map((value) => Chip(
                      label: Text(value),
                      onDeleted: () => onChanged(values.where((v) => v != value).toList()),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

