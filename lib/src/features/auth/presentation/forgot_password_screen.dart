import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/data/auth_repository.dart';
import 'package:sports_app/src/features/auth/presentation/auth_form_helpers.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/auth/presentation/providers/otp_timer_notifier.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/custom_app_bar.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _smsController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _step = 1;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _telephoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
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
        title: 'auth.forgot.otp_error_title'.tr(),
        error: Exception('auth.validation.telephone_required'.tr()),
      );
      return;
    }
    setState(() => _isSendingOtp = true);
    try {
      await ref
          .read(authRepositoryProvider.notifier)
          .requestSms(telephone: telephone, scene: 11);
      ref.read(otpTimerNotifierProvider.notifier).start();
    } catch (e) {
      if (mounted) {
        context.showErrorDialog(
          title: 'auth.forgot.otp_error_title'.tr(),
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  void _goToStep2() {
    if (!(_step1FormKey.currentState?.validate() ?? false)) return;
    setState(() => _step = 2);
  }

  void _goToStep1() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    if (!(_step2FormKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(
          telephone: _telephoneController.text.trim(),
          password: _passwordController.text,
          sms: _smsController.text.trim(),
        );
    if (mounted) {
      ref
          .read(authNotifierProvider)
          .whenOrNull(
            data: (_) => showCustomStatusDialog(
              context: context,
              dialogType: DialogType.success,
              title: 'auth.forgot.success'.tr(),
              buttonText: 'auth.forgot.go_to_login'.tr(),
              onButtonPressed: () {
                while (context.canPop()) {
                  context.pop();
                }
                context.push(AppRoutes.login);
              },
              onCloseSameWithPrimaryButton: true,
            ),
            error: (e, _) => context.showErrorDialog(
              title: 'auth.forgot.error_title'.tr(),
              error: e,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final countdown = ref.watch(otpTimerNotifierProvider);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return PopScope(
      canPop: _step == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToStep1();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(),
        body: Column(
          children: [
            _buildHeroStrip(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                child: _step == 1
                    ? _buildStep1(context, countdown)
                    : _buildStep2(context, isLoading),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStrip(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/image_04.jpg', fit: BoxFit.cover),
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
            bottom: 20,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'auth.forgot.hero_title'.tr(),
                  style: AppTextStyles.display(
                    38,
                    context,
                  ).copyWith(height: 0.9),
                ),
                const SizedBox(height: 4),
                Text(
                  _step == 1
                      ? 'auth.forgot.step1_label'.tr()
                      : 'auth.forgot.step2_label'.tr(),
                  style: AppTextStyles.mono(10).copyWith(letterSpacing: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext context, int countdown) {
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'auth.field.telephone'.tr(),
            child: TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.mono(15).copyWith(color: scheme.onSurface),
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
            label: 'auth.field.sms_code'.tr(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _smsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                _OtpSendButton(
                  countdown: countdown,
                  isSending: _isSendingOtp,
                  phoneEmpty: _telephoneController.text.trim().isEmpty,
                  onTap: _sendOtp,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          PrimaryCtaButton(
            label: 'auth.forgot.next'.tr(),
            isLoading: false,
            onTap: _goToStep2,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, bool isLoading) {
    final scheme = Theme.of(context).colorScheme;
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: 'auth.field.new_password'.tr(),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: AppTextStyles.mono(15).copyWith(color: scheme.onSurface),
              cursorColor: scheme.primary,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: authInputDecoration(
                context,
                hintText: 'auth.field.new_password_hint'.tr(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: scheme.onSurface.withValues(alpha: 0.62),
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
              style: AppTextStyles.mono(15).copyWith(color: scheme.onSurface),
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
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'auth.validation.password_required'.tr();
                if (v != _passwordController.text) {
                  return 'auth.validation.confirm_password_mismatch'.tr();
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 28),
          PrimaryCtaButton(
            label: 'auth.forgot.submit'.tr(),
            isLoading: isLoading,
            onTap: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _OtpSendButton extends StatelessWidget {
  final int countdown;
  final bool isSending;
  final bool phoneEmpty;
  final VoidCallback onTap;

  const _OtpSendButton({
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
