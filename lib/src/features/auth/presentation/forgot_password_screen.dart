import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/data/auth_repository.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/auth/presentation/providers/otp_timer_notifier.dart';
import 'package:sports_app/src/shared_widgets/country_phone_number_text_field.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
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
          .requestSms(
            telephone: telephone,
            scene: 11, // 11 = resetPassword
          );
      ref.read(otpTimerNotifierProvider.notifier).start();
    } catch (e) {
      if (mounted) {
        context.showErrorDialog(title: 'auth.forgot.otp_error_title'.tr(), error: e);
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
            error: (e, _) =>
                context.showErrorDialog(title: 'auth.forgot.error_title'.tr(), error: e),
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
        appBar: AppBar(
          title: Text('auth.forgot.title'.tr()),
          leading: _step == 2
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goToStep1)
              : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _step == 1 ? _buildStep1(countdown) : _buildStep2(isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(int countdown) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          CountryPhoneNumberTextField(
            textEditingController: _telephoneController,
            onCountryCodeChanged: (_) {},
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'auth.validation.telephone_required'.tr() : null,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomTextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textEditingController: _smsController,
                  hintText: 'auth.field.sms_code'.tr(),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'auth.validation.sms_required'.tr() : null,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: countdown > 0 || _isSendingOtp || _telephoneController.text.trim().isEmpty ? Colors.grey : Colors.pink),
                  ),
                  onPressed: countdown > 0 || _isSendingOtp || _telephoneController.text.trim().isEmpty ? null : _sendOtp,
                  child: _isSendingOtp
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          countdown > 0
                              ? 'auth.otp.resend_countdown'.tr(namedArgs: {'seconds': '$countdown'})
                              : 'auth.otp.send'.tr(),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _goToStep2, child: Text('auth.forgot.next'.tr())),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isLoading) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          CustomTextField(
            textEditingController: _passwordController,
            obscureText: _obscurePassword,
            hintText: 'auth.field.new_password'.tr(),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'auth.validation.password_required'.tr() : null,
          ),
          CustomTextField(
            textEditingController: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            hintText: 'auth.field.confirm_password'.tr(),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'auth.validation.password_required'.tr();
              if (v != _passwordController.text) {
                return 'auth.validation.confirm_password_mismatch'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('auth.forgot.submit'.tr()),
          ),
        ],
      ),
    );
  }
}
