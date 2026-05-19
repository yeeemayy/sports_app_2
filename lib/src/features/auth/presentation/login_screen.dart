import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/presentation/auth_form_helpers.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/custom_app_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? returnPath;
  const LoginScreen({super.key, this.returnPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(telephone: _telephoneController.text.trim(), password: _passwordController.text);
      if (mounted) {
        context.go(AppRoutes.home);
        if (widget.returnPath != null) {
          context.push(widget.returnPath!);
        }
      }
    } catch (e) {
      if (!mounted) return;
      context.showErrorDialog(title: 'auth.login.error_title'.tr(), error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          _buildHeroStrip(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'auth.login.subtitle'.tr(),
                      style: AppTextStyles.body(
                        13,
                      ).copyWith(color: scheme.onSurface.withValues(alpha: 0.62)),
                    ),
                    const SizedBox(height: 20),
                    LabeledField(
                      label: 'auth.field.telephone'.tr(),
                      child: TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.mono(15).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: authInputDecoration(
                          context,
                          hintText: 'auth.field.telephone_hint'.tr(),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '+86',
                                  style: AppTextStyles.mono(13).copyWith(color: scheme.onSurface),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 0.5,
                                  height: 18,
                                  color: scheme.onSurface.withValues(alpha: 0.18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'auth.validation.telephone_required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'auth.field.password'.tr(),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.mono(15).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: authInputDecoration(
                          context,
                          hintText: 'auth.field.password_hint'.tr(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: scheme.onSurface.withValues(alpha: 0.62),
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'auth.validation.password_required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.forgotPassword),
                        child: Text(
                          'auth.login.forgot_password'.tr(),
                          style: AppTextStyles.mono(
                            11,
                          ).copyWith(color: scheme.primary, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryCtaButton(
                      label: 'auth.login.cta'.tr(),
                      isLoading: isLoading,
                      onTap: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.login.no_account'.tr(),
                          style: AppTextStyles.body(
                            13,
                          ).copyWith(color: scheme.onSurface.withValues(alpha: 0.62)),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: Text(
                            '  ${'auth.login.register'.tr()} →',
                            style: AppTextStyles.body(
                              13,
                            ).copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStrip(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/image_01.jpeg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scaffoldBg.withValues(alpha: 0.3), scaffoldBg],
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 0.5),
                  ),
                  child: Text(
                    'auth.login.welcome_back'.tr(),
                    style: AppTextStyles.mono(10).copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'auth.login.hero_title'.tr(),
                  style: AppTextStyles.display(46, context).copyWith(height: 0.9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
