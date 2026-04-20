import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/routes/app_router.dart';
import 'package:sports_app/src/routes/app_routes.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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
      backgroundColor: Colors.white,
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
    final nickname = user?.nickname ?? '';

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
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: const ColoredBox(color: Colors.white),
                            ),
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
                const SizedBox(height: 16),
                ...ListTile.divideTiles(
                  context: context,
                  tiles: [
                    _ProfileTile(
                      icon: Icons.logout,
                      label: 'profile.logout'.tr(),
                      onTap: () => _confirmLogout(context, ref),
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : null;
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: context.textTheme.bodyMedium?.copyWith(color: color)),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right),
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
