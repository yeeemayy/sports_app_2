import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/auth_form_helpers.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_app_bar.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_status_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nicknameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            name: _nicknameController.text.trim(),
          );
      if (mounted) {
        await showCustomStatusDialog(
          context: context,
          title: 'auth.register.success_title'.tr(),
          description: 'auth.register.success_description'.tr(),
          buttonText: 'auth.register.login_now'.tr(),
          onButtonPressed: () => context.go(AppRoutes.home),
          dialogType: DialogType.success,
          onCloseSameWithPrimaryButton: true,
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorDialog(
          title: 'auth.register.error_title'.tr(),
          error: e,
        );
      }
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
                    LabeledField(
                      label: 'auth.field.nickname'.tr(),
                      child: TextFormField(
                        controller: _nicknameController,
                        style: AppTextStyles.mono(
                          15,
                        ).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: authInputDecoration(
                          context,
                          hintText: 'auth.field.nickname_hint'.tr(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'auth.validation.nickname_required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'auth.field.username'.tr(),
                      child: TextFormField(
                        controller: _usernameController,
                        style: AppTextStyles.mono(
                          15,
                        ).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: authInputDecoration(
                          context,
                          hintText: 'auth.field.username_hint'.tr(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'auth.validation.username_required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'auth.field.password'.tr(),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: AppTextStyles.mono(
                          15,
                        ).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: authInputDecoration(
                          context,
                          hintText: 'auth.field.password_hint'.tr(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: scheme.onSurface.withValues(alpha: 0.62),
                              size: 18,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'auth.validation.password_required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'auth.field.confirm_password'.tr(),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: AppTextStyles.mono(
                          15,
                        ).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: authInputDecoration(
                          context,
                          hintText: 'auth.field.confirm_password_hint'.tr(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: scheme.onSurface.withValues(alpha: 0.62),
                              size: 18,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (v) => v != _passwordController.text
                            ? 'auth.validation.confirm_password_mismatch'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PrimaryCtaButton(
                      label: 'auth.register.cta'.tr(),
                      isLoading: isLoading,
                      onTap: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.register.have_account'.tr(),
                          style: AppTextStyles.body(13).copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.62),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.login),
                          child: Text(
                            '  ${'auth.register.login'.tr()} →',
                            style: AppTextStyles.body(13).copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/shty_bg_register.jpeg', fit: BoxFit.cover),
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
            child: Text(
              'auth.register.hero_title'.tr(),
              style: AppTextStyles.display(42, context).copyWith(height: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
