import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/auth_providers.dart';
import '../../../core/services/child_service.dart';
import '../../../core/services/therapist_note_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/child.dart';
import '../../../models/enums.dart';
import '../../../models/therapist_note.dart';
import '../../../shared/widgets/custom_icon.dart';

class TherapistPage extends ConsumerWidget {
  const TherapistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat profil: $e')),
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return profile.role == UserRole.therapist
                    ? const _TherapistView()
                    : const _ParentView();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
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
          AppSpacing.gapHMD,
          Text(title, style: AppTextStyles.displayL),
        ],
      ),
    );
  }
}

/// Parent side: link a therapist to the child, view the therapist's notes.
class _ParentView extends ConsumerWidget {
  const _ParentView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(currentChildProvider);

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(title: 'SproutLink'),
          childAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Gagal memuat profil anak: $e'),
            data: (child) {
              if (child == null) return const Text('Profil anak belum tersedia.');
              return child.therapistId == null
                  ? _LinkTherapistForm(childId: child.id)
                  : _LinkedTherapistPanel(child: child);
            },
          ),
        ],
      ),
    );
  }
}

class _LinkTherapistForm extends ConsumerStatefulWidget {
  const _LinkTherapistForm({required this.childId});
  final String childId;

  @override
  ConsumerState<_LinkTherapistForm> createState() => _LinkTherapistFormState();
}

class _LinkTherapistFormState extends ConsumerState<_LinkTherapistForm> {
  final _emailCtrl = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(childServiceProvider).linkTherapistByEmail(
            childId: widget.childId,
            email: _emailCtrl.text.trim(),
          );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hubungkan akun anak dengan terapis pendamping agar terapis dapat mengakses riwayat perkembangan.',
          style: AppTextStyles.bodyM,
        ),
        AppSpacing.gapMD,
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email terapis',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
        if (_error != null) ...[
          AppSpacing.gapSM,
          Text(_error!, style: AppTextStyles.bodyS.copyWith(color: AppColors.error)),
        ],
        AppSpacing.gapMD,
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.peach500),
          onPressed: _isSubmitting ? null : _link,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                )
              : Text('Hubungkan', style: AppTextStyles.headingM.copyWith(color: AppColors.white)),
        ),
      ],
    );
  }
}

class _LinkedTherapistPanel extends ConsumerWidget {
  const _LinkedTherapistPanel({required this.child});
  final Child child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final therapistAsync = ref.watch(userByIdProvider(child.therapistId!));
    final notesAsync = ref.watch(notesForChildProvider(child.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        therapistAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Gagal memuat data terapis: $e'),
          data: (therapist) => Container(
            width: double.infinity,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(color: AppColors.teal100, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terapis Terhubung', style: AppTextStyles.labelL),
                    Text(therapist?.name ?? '-', style: AppTextStyles.headingM),
                  ],
                ),
                TextButton(
                  onPressed: () => ref.read(childServiceProvider).unlinkTherapist(child.id),
                  child: const Text('Putuskan'),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapXL,
        Text('Catatan Terapis', style: AppTextStyles.headingM),
        AppSpacing.gapSM,
        notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Gagal memuat catatan: $e'),
          data: (notes) => notes.isEmpty
              ? Text('Belum ada catatan dari terapis.', style: AppTextStyles.bodyM)
              : Column(children: notes.map((n) => _NoteCard(note: n)).toList()),
        ),
      ],
    );
  }
}

/// Therapist side: pick a linked child, view/add notes.
class _TherapistView extends ConsumerStatefulWidget {
  const _TherapistView();

  @override
  ConsumerState<_TherapistView> createState() => _TherapistViewState();
}

class _TherapistViewState extends ConsumerState<_TherapistView> {
  Child? _selectedChild;

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(childrenForTherapistProvider);

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(title: 'SproutLink'),
          childrenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Gagal memuat daftar anak: $e'),
            data: (children) {
              if (children.isEmpty) {
                return Text(
                  'Belum ada orang tua yang menghubungkan akun anak ke akun Anda.',
                  style: AppTextStyles.bodyM,
                );
              }
              _selectedChild ??= children.first;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: children.map((c) {
                      final isSelected = _selectedChild?.id == c.id;
                      return ChoiceChip(
                        label: Text(c.name),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedChild = c),
                      );
                    }).toList(),
                  ),
                  AppSpacing.gapXL,
                  if (_selectedChild != null) _ChildNotesPanel(child: _selectedChild!),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChildNotesPanel extends ConsumerWidget {
  const _ChildNotesPanel({required this.child});
  final Child child;

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final observationCtrl = TextEditingController();
    final recommendationCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: observationCtrl,
                decoration: const InputDecoration(labelText: 'Observasi'),
                maxLines: 3,
              ),
              TextField(
                controller: recommendationCtrl,
                decoration: const InputDecoration(labelText: 'Rekomendasi'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (confirmed != true) return;

    final therapistId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (therapistId == null) return;

    final noteService = ref.read(therapistNoteServiceProvider);
    await noteService.addNote(TherapistNote(
      id: noteService.newNoteId(),
      childId: child.id,
      therapistId: therapistId,
      sessionDate: DateTime.now(),
      observation: observationCtrl.text.trim(),
      recommendation: recommendationCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesForChildProvider(child.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Catatan untuk ${child.name}', style: AppTextStyles.headingM),
            TextButton(
              onPressed: () => _addNote(context, ref),
              child: const Text('+ Tambah Catatan'),
            ),
          ],
        ),
        AppSpacing.gapSM,
        notesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Gagal memuat catatan: $e'),
          data: (notes) => notes.isEmpty
              ? Text('Belum ada catatan.', style: AppTextStyles.bodyM)
              : Column(children: notes.map((n) => _NoteCard(note: n)).toList()),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final TherapistNote note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral800.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('d MMM y').format(note.sessionDate), style: AppTextStyles.caption),
          AppSpacing.gapXS,
          Text('Observasi', style: AppTextStyles.labelL),
          Text(note.observation, style: AppTextStyles.bodyM),
          AppSpacing.gapXS,
          Text('Rekomendasi', style: AppTextStyles.labelL),
          Text(note.recommendation, style: AppTextStyles.bodyM),
        ],
      ),
    );
  }
}
