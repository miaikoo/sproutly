import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/services/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/auth_background.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _obscure = true;
  String? _errorText;

  static const String _googleSvg = '''
<svg viewBox="0 0 24 24" width="24" height="24">
  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22c-.87-2.6-2.87-4.53-5.84-4.53z"/>
  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
</svg>
''';

  static const String _facebookSvg = '''
<svg viewBox="0 0 24 24" width="24" height="24">
  <path fill="#1877F2" d="M19 10h-3V8c0-.5.5-1 1-1h2V4h-3c-2.2 0-4 1.8-4 4v2H9v3h3v9h4v-9h3l1-3z"/>
</svg>
''';

  static const String _appleSvg = '''
<svg viewBox="0 0 24 24" width="24" height="24">
  <path fill="#000000" d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.22.67-2.94 1.5-.63.73-1.18 1.87-1.03 2.99 1.11.09 2.27-.56 2.98-1.43z"/>
</svg>
''';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await ref.read(authServiceProvider).login(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _errorText = 'Isi email dulu, lalu ketuk "Lupa password?" lagi.');
      return;
    }

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tautan reset password sudah dikirim ke $email.')),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
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
                        _textField(
                          _emailCtrl,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        AppSpacing.gapMD,
                        _passwordField(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Lupa password?',
                              style: AppTextStyles.bodyS.copyWith(
                                color: const Color(0xFFC4806C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
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
                            onPressed: () => context.go(AppRoutes.register),
                            child: Text.rich(
                              TextSpan(
                                style: AppTextStyles.bodyM,
                                children: [
                                  const TextSpan(text: 'Tidak punya akun? ', style: TextStyle(color: Color(0xFF1C2220))),
                                  TextSpan(
                                    text: 'Daftar',
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
                        AppSpacing.gapMD,
                        _divider(),
                        AppSpacing.gapLG,
                        _socialButtons(),
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
          Expanded(child: _TabPill(label: 'Masuk', selected: true, onTap: () {})),
          Expanded(
            child: _TabPill(
              label: 'Daftar',
              selected: false,
              onTap: () => context.go(AppRoutes.register),
            ),
          ),
        ],
      ),
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

  Widget _submitButton() {
    // Determine status for enabled/disabled color styling to match Figma disabled state
    final isFormEmpty = _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty;
    
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
                'Masuk',
                style: TextStyle(
                  color: isFormEmpty ? const Color(0xFFB0C0BE) : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFAFB4BE), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Atau',
            style: AppTextStyles.bodyM.copyWith(
              color: const Color(0xFF6C6C6C),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFAFB4BE), thickness: 1)),
      ],
    );
  }

  Widget _socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(_googleSvg),
        const SizedBox(width: 32),
        _socialButton(_facebookSvg),
        const SizedBox(width: 32),
        _socialButton(_appleSvg),
      ],
    );
  }

  Widget _socialButton(String svgString) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF7EA29C),
            width: 2.67,
          ),
        ),
        alignment: Alignment.center,
        child: SvgPicture.string(
          svgString,
          width: 32,
          height: 32,
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
