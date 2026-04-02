import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/shared_widgets/country_phone_number_text_field.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _countryCode = '+86';

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
   try {
     await ref.read(authNotifierProvider.notifier).login(
       telephone: _telephoneController.text.trim(),
       password: _passwordController.text,
     );
     if (mounted) context.go('/home');
   } catch (e) {
     if (!mounted) return;
     context.showErrorDialog(title: 'auth.login.error_title'.tr(), error: e);
   }
  }

  @override
  Widget build(BuildContext context) {
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
                    'auth.login.title'.tr(),
                    style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),
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
                  hintText: 'auth.field.password'.tr(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v == null || v.isEmpty
                      ? 'auth.validation.password_required'.tr()
                      : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/auth/forgot-password'),
                    child: Text('auth.login.forgot_password'.tr()),
                  ),
                ),
                const SizedBox(height: 24),
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
                      : Text('auth.login.submit'.tr()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('auth.login.no_account'.tr()),
                    TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: Text('auth.login.register'.tr()),
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
