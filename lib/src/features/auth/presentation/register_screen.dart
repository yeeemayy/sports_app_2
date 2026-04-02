import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/data/auth_repository.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/auth/presentation/providers/otp_timer_notifier.dart';
import 'package:sports_app/src/shared_widgets/country_phone_number_text_field.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

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
  String _countryCode = '+86';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('auth.validation.telephone_required'.tr())));
      return;
    }
    try {
      await ref
          .read(authRepositoryProvider.notifier)
          .requestSms(
            telephone: telephone,
            scene: 10, // 10 = register
          );
      ref.read(otpTimerNotifierProvider.notifier).start();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authNotifierProvider.notifier)
        .register(
          nickname: _nicknameController.text.trim(),
          telephone: _telephoneController.text.trim(),
          password: _passwordController.text,
          sms: _smsController.text.trim(),
        );
    if (mounted) {
      ref
          .read(authNotifierProvider)
          .whenOrNull(
            error: (e, _) =>
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final countdown = ref.watch(otpTimerNotifierProvider);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'auth.register.title'.tr(),
                    style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  textEditingController: _nicknameController,
                  hintText: 'auth.field.nickname_hint'.tr(),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'auth.validation.nickname_required'.tr()
                      : null,
                ),
                CountryPhoneNumberTextField(
                  textEditingController: _telephoneController,
                  onCountryCodeChanged: (code) => setState(() => _countryCode = code),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'auth.validation.telephone_required'.tr()
                      : null,
                ),
                CustomTextField(
                  textEditingController: _passwordController,
                  obscureText: _obscurePassword,
                  hintText: 'auth.field.password_hint'.tr(),
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
                  hintText: 'auth.field.confirm_password_hint'.tr(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'auth.validation.confirm_password_mismatch'.tr()
                      : null,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        textEditingController: _smsController,
                        keyboardType: TextInputType.number,
                        hintText: 'auth.field.sms_code'.tr(),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'auth.validation.sms_required'.tr()
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        onPressed: countdown > 0 ? null : _sendOtp,
                        child: Text(
                          countdown > 0
                              ? 'auth.otp.resend_countdown'.tr(args: ['$countdown'])
                              : 'auth.otp.send'.tr(),
                        ),
                      ),
                    ),
                  ],
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
                      : Text('auth.register.submit'.tr()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('auth.register.have_account'.tr()),
                    TextButton(
                      onPressed: () => context.push('/auth/login'),
                      child: Text('auth.register.login'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
