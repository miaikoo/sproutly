import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/enums.dart';
import '../widgets/auth_background.dart';

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
  bool _obscure = true;
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
      backgroundColor: AppColors.steel100,
      body: AuthBackground(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // White card panel
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFAFCFB), // matches Figma reference background color
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 48, AppSpacing.xl, AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _tabs(),
                        AppSpacing.gapXL,
                        _roleToggle(),
                        AppSpacing.gapXL,
                        Text(
                          _role == UserRole.parent ? 'Data Orang Tua' : 'Data Terapis',
                          style: AppTextStyles.headingM.copyWith(
                            color: const Color(0xFF446860),
                          ),
                        ),
                        AppSpacing.gapSM,
                        _textField(
                          _parentNameCtrl,
                          _role == UserRole.parent ? 'Nama orang tua' : 'Nama terapis',
                        ),
                        AppSpacing.gapMD,
                        _textField(
                          _emailCtrl,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        AppSpacing.gapMD,
                        _passwordField(),
                        if (_role == UserRole.parent) ...[
                          AppSpacing.gapXL,
                          Text(
                            'Profil Anak',
                            style: AppTextStyles.headingM.copyWith(
                              color: const Color(0xFF446860),
                            ),
                          ),
                          AppSpacing.gapSM,
                          _textField(_childNameCtrl, 'Nama anak'),
                          AppSpacing.gapMD,
                          _datePickerField(),
                          AppSpacing.gapMD,
                          _severityField(),
                        ],
                        if (_errorText != null) ...[
                          AppSpacing.gapMD,
                          Text(
                            _errorText!,
                            style: AppTextStyles.bodyS.copyWith(color: AppColors.error),
                          ),
                        ],
                        AppSpacing.gapXL,
                        _submitButton(),
                        AppSpacing.gapMD,
                        Center(
                          child: TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: Text.rich(
                              TextSpan(
                                style: AppTextStyles.bodyM,
                                children: [
                                  const TextSpan(text: 'Sudah punya akun? ', style: TextStyle(color: Color(0xFF1C2220))),
                                  TextSpan(
                                    text: 'Masuk',
                                    style: AppTextStyles.bodyM.copyWith(
                                      color: const Color(0xFFC4806C),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Logo positioned exactly overlapping the top rounded border
            Positioned(
              top: -24,
              child: Container(
                color: const Color(0xFFFAFCFB),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _logo(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Text.rich(
      TextSpan(
        style: AppTextStyles.displayL.copyWith(
          color: const Color(0xFF5E8880), // Primary teal 600
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        children: [
          const TextSpan(text: 'Sprout'),
          const TextSpan(text: '.', style: TextStyle(color: Color(0xFFC4806C))), // Peach 500
          const TextSpan(text: 'ly'),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFFD2E8E5), // Light green-teal container
        borderRadius: BorderRadius.all(Radius.circular(68)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              label: 'Masuk',
              selected: false,
              onTap: () => context.go(AppRoutes.login),
            ),
          ),
          Expanded(child: _TabPill(label: 'Daftar', selected: true, onTap: () {})),
        ],
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyM,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF8CB0A8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? '$label wajib diisi' : null,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscure,
      style: AppTextStyles.bodyM,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Color(0xFF8CB0A8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          color: const Color(0xFF446860),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (value) => (value == null || value.trim().isEmpty) ? 'Password wajib diisi' : null,
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
          labelText: 'Tanggal lahir anak',
          labelStyle: const TextStyle(color: Color(0xFF8CB0A8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
          ),
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
        labelStyle: const TextStyle(color: Color(0xFF8CB0A8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF446860), width: 2),
        ),
      ),
      items: Severity.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
          .toList(),
      onChanged: (value) => setState(() => _severity = value ?? _severity),
    );
  }

  Widget _submitButton() {
    final isParentFormEmpty = _parentNameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _childNameCtrl.text.isEmpty ||
        _childBirthDate == null;
    final isTherapistFormEmpty = _parentNameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty;
        
    final isFormEmpty = _role == UserRole.parent ? isParentFormEmpty : isTherapistFormEmpty;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: isFormEmpty ? const Color(0xFFE4EDEB) : const Color(0xFF446860),
          foregroundColor: isFormEmpty ? const Color(0xFFB0C0BE) : Colors.white,
          disabledBackgroundColor: const Color(0xFFE4EDEB),
          disabledForegroundColor: const Color(0xFFB0C0BE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: _isSubmitting ? null : _submit,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
              )
            : Text(
                'Daftar',
                style: TextStyle(
                  color: isFormEmpty ? const Color(0xFFB0C0BE) : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF446860) : const Color(0xFF9ABCB6),
      borderRadius: const BorderRadius.all(Radius.circular(36)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(36)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.buttonM.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
