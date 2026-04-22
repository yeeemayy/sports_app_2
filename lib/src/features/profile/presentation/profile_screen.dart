import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/data/auth_storage_service.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/providers/theme_provider.dart';
import 'package:sports_app/src/routes/app_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showCustomStatusDialog(
      context: context,
      dialogType: DialogType.custom,
      overrideIcon: Icons.delete_forever_rounded,
      overrideIconBackgroundColor: Colors.red,
      title: 'profile.delete_account_confirm_title'.tr(),
      description: 'profile.delete_account_confirm_message'.tr(),
      buttonText: 'profile.delete_account_confirm_proceed'.tr(),
      buttonBackgroundColor: Colors.red,
      onButtonPressed: () {
        context.pop();
        _showPasswordConfirmDialog(context, ref);
      },
      secondaryButton: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => context.pop(),
          child: Text('profile.logout_confirm_cancel'.tr()),
        ),
      ),
      showCloseButton: false,
    );
  }

  void _showPasswordConfirmDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final errorNotifier = ValueNotifier<String?>(null);

    showCustomStatusDialog(
      context: context,
      dialogType: DialogType.custom,
      overrideIcon: Icons.lock_outline_rounded,
      overrideIconBackgroundColor: Colors.red,
      title: 'profile.delete_account_password_title'.tr(),
      overrideContent: _PasswordConfirmContent(
        controller: passwordController,
        errorNotifier: errorNotifier,
      ),
      buttonText: 'profile.delete_account'.tr(),
      buttonBackgroundColor: Colors.red,
      onButtonPressed: () async {
        if (passwordController.text.trim().isEmpty) {
          errorNotifier.value = 'profile.delete_account_password_empty'.tr();
          return;
        }
        final storage = ref.read(authStorageServiceProvider.notifier);
        final credentials = await storage.readCredentials();
        if (credentials == null || passwordController.text != credentials.password) {
          errorNotifier.value = 'profile.delete_account_password_incorrect'.tr();
          return;
        }
        errorNotifier.value = null;
        context.pop();
        final notifier = ref.read(authNotifierProvider.notifier);
        try {
          await notifier.deleteAccount();
          if (context.mounted) context.go(AppRoutes.home);
        } catch (e) {
          if (context.mounted) {
            context.showErrorDialog(title: 'profile.delete_account_error_title'.tr(), error: e);
          }
        }
      },
      secondaryButton: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => context.pop(),
          child: Text('profile.logout_confirm_cancel'.tr()),
        ),
      ),
      showCloseButton: false,
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showCustomStatusDialog(
      context: context,
      dialogType: DialogType.custom,
      overrideIcon: Icons.logout_rounded,
      overrideIconBackgroundColor: Colors.red,
      title: 'profile.logout_confirm_title'.tr(),
      description: 'profile.logout_confirm_message'.tr(),
      buttonText: 'profile.logout'.tr(),
      buttonBackgroundColor: Colors.red,
      onButtonPressed: () async {
        context.pop();
        await ref.read(authNotifierProvider.notifier).logout();
        context.go(AppRoutes.home);
      },
      secondaryButton: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => context.pop(),
          child: Text('profile.logout_confirm_cancel'.tr()),
        ),
      ),
      showCloseButton: false,
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final current = context.locale;
    final languages = [
      (locale: const Locale('zh', 'CN'), label: 'profile.language_zh_cn'),
      (locale: const Locale('en', 'GB'), label: 'profile.language_en_gb'),
    ];

    showModalBottomSheet<void>(
      context: rootNavigatorKey.currentContext ?? context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Text(
                  'profile.toggle_language'.tr(),
                  style: sheetContext.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 0),
              ...languages.map(
                (lang) => ListTile(
                  title: Text(lang.label.tr()),
                  trailing: current == lang.locale ? const Icon(Icons.check_rounded) : null,
                  onTap: () {
                    context.setLocale(lang.locale);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState.hasValue && (authState.value?.isAuthenticated ?? false);
    final user = authState.value?.user;
    final avatarUrl = user?.avatarUrl;
    debugPrint(avatarUrl);
    final nickname = user?.nickname ?? '';
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              if (isAuthenticated) ...[
                Center(
                  child: ClipOval(
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Shimmer.fromColors(
                                baseColor: AppTheme.of(context).shimmerBase,
                                highlightColor: AppTheme.of(context).shimmerHighlight,
                                child: const ColoredBox(color: Colors.grey),
                              );
                            },
                            errorBuilder: (context, url, error) => AvatarFallback(),
                          )
                        : AvatarFallback(),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    nickname,
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.register),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                          ),
                          child: Text('auth.register.register'.tr()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push(AppRoutes.login),
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                          child: Text('auth.login.login'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              _ProfileSection(
                label: 'profile.section_settings'.tr(),
                tiles: [
                  if (isAuthenticated)
                    _ProfileTile(
                      icon: Icons.person_outline,
                      label: 'profile.edit_button'.tr(),
                      onTap: () => context.push(AppRoutes.profileEditFull),
                    ),
                  _ProfileTile(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    label: 'profile.toggle_dark_mode'.tr(),
                    onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(
                        isDark ? ThemeMode.light : ThemeMode.dark),
                    trailing: Switch(
                      value: isDark,
                      onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                  _ProfileTile(
                    icon: Icons.language,
                    label: 'profile.toggle_language'.tr(),
                    onTap: () => _showLanguagePicker(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileSection(
                label: 'profile.section_legal'.tr(),
                tiles: [
                  _ProfileTile(
                    icon: Icons.privacy_tip_outlined,
                    label: 'profile.privacy_policy'.tr(),
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.description_outlined,
                    label: 'profile.terms_of_use'.tr(),
                    onTap: () {},
                  ),
                ],
              ),
              if (isAuthenticated) ...[
                SizedBox(height: 16),
                _ProfileSection(
                  label: 'profile.section_danger_zone'.tr(),
                  tiles: [
                    _ProfileTile(
                      icon: Icons.person_remove_outlined,
                      label: 'profile.delete_account'.tr(),
                      onTap: () => _confirmDeleteAccount(context, ref),
                    ),
                  ],
                ),
              ],
              if (isAuthenticated) ...[
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: Icon(Icons.logout),
                    label: Text('profile.logout'.tr()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordConfirmContent extends StatefulWidget {
  const _PasswordConfirmContent({required this.controller, required this.errorNotifier});

  final TextEditingController controller;
  final ValueNotifier<String?> errorNotifier;

  @override
  State<_PasswordConfirmContent> createState() => _PasswordConfirmContentState();
}

class _PasswordConfirmContentState extends State<_PasswordConfirmContent> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.errorNotifier,
      builder: (context, error, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'profile.delete_account_password_message'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              textEditingController: widget.controller,
              obscureText: _obscure,
              errorText: widget.errorNotifier.value,
              label: 'profile.delete_account_password_label'.tr(),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'profile.delete_account_password_empty'.tr()
                  : null,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : null;
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: context.textTheme.bodyMedium?.copyWith(color: color)),
      trailing: trailing ?? (isDestructive ? null : const Icon(Icons.chevron_right)),
      onTap: onTap,
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.label, required this.tiles});

  final String label;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
          separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16, height: 0),
        ),
      ],
    );
  }
}
