import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _parentNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _childNameCtrl = TextEditingController();

  DateTime? _childBirthDate;
  Severity _severity = Severity.mild;
  UserRole _role = UserRole.parent;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _parentNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _childNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 4),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) setState(() => _childBirthDate = picked);
  }

  Future<void> _submit() async {
    final needsChildData = _role == UserRole.parent;
    if (!_formKey.currentState!.validate() || (needsChildData && _childBirthDate == null)) {
      setState(() => _errorText =
          (needsChildData && _childBirthDate == null) ? 'Tanggal lahir anak wajib diisi.' : null);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      if (_role == UserRole.parent) {
        await ref.read(authServiceProvider).registerParent(
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
              parentName: _parentNameCtrl.text.trim(),
              childName: _childNameCtrl.text.trim(),
              childBirthDate: _childBirthDate!,
              childSeverity: _severity,
            );
      } else {
        await ref.read(authServiceProvider).registerTherapist(
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
              name: _parentNameCtrl.text.trim(),
            );
      }
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daftar Akun', style: AppTextStyles.displayL),
                    AppSpacing.gapXS,
                    Text(
                      'Isi data orang tua/caregiver dan profil anak.',
                      style: AppTextStyles.bodyM,
                    ),
                    AppSpacing.gapXL,
                    _roleToggle(),
                    AppSpacing.gapXL,
                    Text(
                      _role == UserRole.parent ? 'Data Orang Tua' : 'Data Terapis',
                      style: AppTextStyles.headingM,
                    ),
                    AppSpacing.gapSM,
                    _textField(_parentNameCtrl, _role == UserRole.parent ? 'Nama orang tua' : 'Nama terapis'),
                    AppSpacing.gapMD,
                    _textField(_emailCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                    AppSpacing.gapMD,
                    _textField(_passwordCtrl, 'Password', obscure: true),
                    if (_role == UserRole.parent) ...[
                      AppSpacing.gapXL,
                      Text('Profil Anak', style: AppTextStyles.headingM),
                      AppSpacing.gapSM,
                      _textField(_childNameCtrl, 'Nama anak'),
                      AppSpacing.gapMD,
                      _datePickerField(),
                      AppSpacing.gapMD,
                      _severityField(),
                    ],
                    if (_errorText != null) ...[
                      AppSpacing.gapMD,
                      Text(_errorText!, style: AppTextStyles.bodyS.copyWith(color: AppColors.error)),
                    ],
                    AppSpacing.gapXL,
                    _submitButton(),
                    AppSpacing.gapMD,
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: Text('Sudah punya akun? Masuk', style: AppTextStyles.bodyM),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleToggle() {
    return SegmentedButton<UserRole>(
      segments: const [
        ButtonSegment(value: UserRole.parent, label: Text('Orang Tua')),
        ButtonSegment(value: UserRole.therapist, label: Text('Terapis')),
      ],
      selected: {_role},
      onSelectionChanged: (selection) => setState(() => _role = selection.first),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyM,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(AppRadius.md)),
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _datePickerField() {
    final label = _childBirthDate == null
        ? 'Tanggal lahir anak'
        : '${_childBirthDate!.day}/${_childBirthDate!.month}/${_childBirthDate!.year}';
    return InkWell(
      onTap: _pickBirthDate,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.all(AppRadius.md)),
        ),
        child: Text(label, style: AppTextStyles.bodyM),
      ),
    );
  }

  Widget _severityField() {
    return DropdownButtonFormField<Severity>(
      initialValue: _severity,
      decoration: InputDecoration(
        labelText: 'Tingkat perkembangan',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(AppRadius.md)),
      ),
      items: Severity.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
          .toList(),
      onChanged: (value) => setState(() => _severity = value ?? _severity),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.peach500,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        onPressed: _isSubmitting ? null : _submit,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
              )
            : Text('Daftar', style: AppTextStyles.headingL.copyWith(color: AppColors.white)),
      ),
    );
  }
}
