import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shenghaotiyu/src/core/exceptions/app_exception.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/auth/data/auth_repository.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/auth_form_helpers.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/otp_timer_notifier.dart';
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
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _smsController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _telephoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty) {
      context.showErrorDialog(
        title: 'auth.register.otp_error_title'.tr(),
        error: AppException('auth.validation.telephone_required'.tr()),
      );
      return;
    }
    setState(() => _isSendingOtp = true);
    try {
      await ref
          .read(authRepositoryProvider.notifier)
          .requestSms(telephone: telephone, scene: 10);
      ref.read(otpTimerNotifierProvider.notifier).start();
    } catch (e) {
      if (mounted) {
        context.showErrorDialog(
          title: 'auth.register.otp_error_title'.tr(),
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            nickname: _nicknameController.text.trim(),
            telephone: _telephoneController.text.trim(),
            password: _passwordController.text,
            sms: _smsController.text.trim(),
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
    final countdown = ref.watch(otpTimerNotifierProvider);
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
                      label: 'auth.field.telephone'.tr(),
                      child: TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.mono(
                          15,
                        ).copyWith(color: scheme.onSurface),
                        cursorColor: scheme.primary,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
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
                                  style: AppTextStyles.mono(
                                    13,
                                  ).copyWith(color: scheme.onSurface),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 0.5,
                                  height: 18,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.18,
                                  ),
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
                    const SizedBox(height: 14),
                    LabeledField(
                      label: 'auth.field.sms_code'.tr(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _smsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: AppTextStyles.mono(
                                15,
                              ).copyWith(color: scheme.onSurface),
                              cursorColor: scheme.primary,
                              onTapOutside: (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: authInputDecoration(
                                context,
                                hintText: 'auth.field.sms_code'.tr(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'auth.validation.sms_required'.tr()
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _OtpButton(
                            countdown: countdown,
                            isSending: _isSendingOtp,
                            phoneEmpty: _telephoneController.text
                                .trim()
                                .isEmpty,
                            onTap: _sendOtp,
                          ),
                        ],
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

class _OtpButton extends StatelessWidget {
  final int countdown;
  final bool isSending;
  final bool phoneEmpty;
  final VoidCallback onTap;

  const _OtpButton({
    required this.countdown,
    required this.isSending,
    required this.phoneEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = countdown > 0 || isSending || phoneEmpty;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled ? Theme.of(context).dividerColor : scheme.primary,
            width: 0.5,
          ),
        ),
        child: Center(
          child: isSending
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.primary,
                  ),
                )
              : Text(
                  countdown > 0
                      ? 'auth.otp.resend_countdown'.tr(
                          namedArgs: {'seconds': '$countdown'},
                        )
                      : 'auth.otp.send'.tr(),
                  style: AppTextStyles.mono(11).copyWith(
                    color: disabled
                        ? scheme.onSurface.withValues(alpha: 0.36)
                        : scheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
        ),
      ),
    );
  }
}
