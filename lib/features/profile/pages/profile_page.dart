import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/active_child.dart';
import '../../../core/services/auth_providers.dart';
import '../../../core/services/child_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/child.dart';
import '../../../models/enums.dart';
import '../../../shared/widgets/page_header.dart';

/// Picks which child the app is working with, and opens each child's profile.
///
/// A family can have more than one child in the programme. The selection is
/// saved on the device rather than in Firestore — it is a per-device preference,
/// not data about the child.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenForParentProvider);
    final activeId = ref.watch(currentChildProvider).valueOrNull?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                PageHeader(
                  title: 'Profil',
                  actions: [
                    IconButton(
                      onPressed: () => _addChild(context, ref),
                      icon: const Icon(Icons.add, size: 30),
                      color: AppColors.peach500,
                      tooltip: 'Tambah profil',
                    ),
                  ],
                ),
                Expanded(
                  child: childrenAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: AppSpacing.pagePadding,
                        child: Text('Gagal memuat profil: $e', style: AppTextStyles.bodyM),
                      ),
                    ),
                    data: (children) => ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.huge,
                      ),
                      children: [
                        for (final child in children) ...[
                          _ChildCard(
                            child: child,
                            isActive: child.id == activeId,
                            onSelect: () => _select(ref, child),
                            onOpen: () => context.push(AppRoutes.childProfilePath(child.id)),
                          ),
                          AppSpacing.gapMD,
                        ],
                        AppSpacing.gapSM,
                        _AddProfileCard(onTap: () => _addChild(context, ref)),
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

  Future<void> _select(WidgetRef ref, Child child) =>
      ref.read(activeChildIdProvider.notifier).select(child.id);

  /// Collects the minimum a profile cannot exist without; preferences, targets
  /// and a photo are added afterwards on the profile page.
  Future<void> _addChild(BuildContext context, WidgetRef ref) async {
    final parentId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (parentId == null) return;

    final result = await showDialog<({String name, DateTime birthDate, Severity severity})>(
      context: context,
      builder: (context) => const _AddChildDialog(),
    );
    if (result == null) return;

    final child = await ref.read(childServiceProvider).addChild(
          parentId: parentId,
          name: result.name,
          birthDate: result.birthDate,
          severity: result.severity,
        );

    // Switch straight to the new profile — adding one and then having to pick it
    // would be a pointless second step.
    await ref.read(activeChildIdProvider.notifier).select(child.id);
    if (context.mounted) context.push(AppRoutes.childProfilePath(child.id));
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.isActive,
    required this.onSelect,
    required this.onOpen,
  });

  final Child child;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isActive,
      child: Material(
        color: AppColors.teal100,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          // Tapping the card opens the profile; the circle on the right switches
          // which child the rest of the app works with.
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _Avatar(photoUrl: child.photoUrl),
                AppSpacing.gapHMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headingL,
                      ),
                      if (isActive)
                        Text('Profil aktif', style: AppTextStyles.bodyS)
                      else
                        Text(
                          '${child.ageInYears(DateTime.now())} tahun',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: isActive ? null : onSelect,
                  tooltip: isActive ? 'Profil aktif' : 'Jadikan profil aktif',
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.peach500 : AppColors.transparent,
                      border: isActive
                          ? null
                          : Border.all(color: AppColors.peach500, width: 2),
                    ),
                    child: isActive
                        ? const Icon(Icons.check, size: 18, color: AppColors.white)
                        : null,
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});

  final String photoUrl;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: _size / 2,
      backgroundColor: AppColors.peach300,
      child: ClipOval(
        child: photoUrl.isEmpty
            ? SvgPicture.asset(
                'assets/images/profile_pic.svg',
                width: _size,
                height: _size,
                fit: BoxFit.cover,
              )
            : Image.network(
                photoUrl,
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SvgPicture.asset(
                  'assets/images/profile_pic.svg',
                  width: _size,
                  height: _size,
                ),
              ),
      ),
    );
  }
}

class _AddProfileCard extends StatelessWidget {
  const _AddProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tambah profil baru',
      child: Material(
        color: AppColors.peach50,
        borderRadius: AppRadius.card,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: DottedBorder(
            options: const RoundedRectDottedBorderOptions(
              radius: AppRadius.lg,
              color: AppColors.peach500,
              strokeWidth: 2,
              dashPattern: [8, 6],
              padding: EdgeInsets.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.peach500, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 18, color: AppColors.peach500),
                  ),
                  AppSpacing.gapHSM,
                  Text('Tambah Profil Baru', style: AppTextStyles.headingM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddChildDialog extends StatefulWidget {
  const _AddChildDialog();

  @override
  State<_AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<_AddChildDialog> {
  final _nameCtrl = TextEditingController();
  DateTime? _birthDate;
  Severity _severity = Severity.moderate;

  static const _severityLabels = {
    Severity.mild: 'Ringan',
    Severity.moderate: 'Sedang',
    Severity.severe: 'Berat',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameCtrl.text.trim().isNotEmpty && _birthDate != null;

    return AlertDialog(
      title: const Text('Profil Anak Baru'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nama anak'),
              onChanged: (_) => setState(() {}),
            ),
            AppSpacing.gapMD,
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanggal lahir'),
              subtitle: Text(
                _birthDate == null
                    ? 'Belum dipilih'
                    : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined, size: 20),
              onTap: _pickDate,
            ),
            AppSpacing.gapXS,
            Text('Tingkat perkembangan', style: AppTextStyles.labelL),
            AppSpacing.gapXS,
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final entry in _severityLabels.entries)
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _severity == entry.key,
                    onSelected: (_) => setState(() => _severity = entry.key),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        TextButton(
          onPressed: canSave
              ? () => Navigator.pop(context, (
                    name: _nameCtrl.text.trim(),
                    birthDate: _birthDate!,
                    severity: _severity,
                  ))
              : null,
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 5),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }
}
