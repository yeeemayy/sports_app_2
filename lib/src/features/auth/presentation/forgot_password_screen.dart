import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/data/auth_repository.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/features/auth/presentation/providers/otp_timer_notifier.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _smsController = TextEditingController();
  bool _obscurePassword = true;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.validation.telephone_required'.tr())),
      );
      return;
    }
    try {
      await ref.read(authRepositoryProvider.notifier).requestSms(
        telephone: telephone,
        scene: 11, // 11 = resetPassword
      );
      ref.read(otpTimerNotifierProvider.notifier).start();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).resetPassword(
      telephone: _telephoneController.text.trim(),
      password: _passwordController.text,
      sms: _smsController.text.trim(),
    );
    if (mounted) {
      ref.read(authNotifierProvider).whenOrNull(
        data: (_) => setState(() => _resetSuccess = true),
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_resetSuccess) {
      return Scaffold(
        appBar: AppBar(title: Text('auth.forgot.title'.tr())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text('auth.forgot.success'.tr(),
                    style: context.textTheme.titleMedium),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text('auth.forgot.go_to_login'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final countdown = ref.watch(otpTimerNotifierProvider);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: Text('auth.forgot.title'.tr())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'auth.field.telephone'.tr(),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'auth.validation.telephone_required'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'auth.field.new_password'.tr(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'auth.validation.password_required'.tr()
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _smsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'auth.field.sms_code'.tr(),
                          prefixIcon: const Icon(Icons.sms_outlined),
                        ),
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
                              ? 'auth.otp.resend_countdown'
                                  .tr(args: ['$countdown'])
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('auth.forgot.submit'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
