import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shenghaotiyu/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shenghaotiyu/src/core/utils/app_info.dart';
import 'package:shenghaotiyu/src/extensions/context_extensions.dart';
import 'package:shenghaotiyu/src/features/auth/data/auth_storage_service.dart';
import 'package:shenghaotiyu/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:shenghaotiyu/src/features/community/domain/models/community_post.dart';
import 'package:shenghaotiyu/src/core/remote_config_provider.dart';
import 'package:shenghaotiyu/src/providers/theme_provider.dart';
import 'package:shenghaotiyu/src/routes/app_router.dart';
import 'package:shenghaotiyu/src/routes/app_routes.dart';
import 'package:shenghaotiyu/src/shared_widgets/avatar.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_status_dialog.dart';
import 'package:shenghaotiyu/src/shared_widgets/custom_text_field.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // ── Dialogs & pickers (logic unchanged) ─────────────────────────────────────

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
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
        if (credentials == null ||
            passwordController.text != credentials.password) {
          errorNotifier.value = 'profile.delete_account_password_incorrect'
              .tr();
          return;
        }
        errorNotifier.value = null;
        if (context.mounted) context.pop();
        final notifier = ref.read(authNotifierProvider.notifier);
        try {
          await notifier.deleteAccount();
          if (context.mounted) context.go(AppRoutes.home);
        } catch (e) {
          if (context.mounted) {
            context.showErrorDialog(
              title: 'profile.delete_account_error_title'.tr(),
              error: e,
            );
          }
        }
      },
      secondaryButton: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
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
        if (context.mounted) context.go(AppRoutes.home);
      },
      secondaryButton: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () => context.pop(),
          child: Text('profile.logout_confirm_cancel'.tr()),
        ),
      ),
      showCloseButton: false,
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    final options = [
      (
        mode: ThemeMode.light,
        label: 'profile.theme_light',
        icon: Icons.light_mode_rounded,
      ),
      (
        mode: ThemeMode.dark,
        label: 'profile.theme_dark',
        icon: Icons.dark_mode_rounded,
      ),
      (
        mode: ThemeMode.system,
        label: 'profile.theme_system',
        icon: Icons.brightness_auto_rounded,
      ),
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
                  'profile.toggle_dark_mode'.tr(),
                  style: sheetContext.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 0),
              ...options.map(
                (opt) => ListTile(
                  leading: Icon(opt.icon),
                  title: Text(opt.label.tr()),
                  trailing: current == opt.mode
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(opt.mode);
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
                  style: sheetContext.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 0),
              ...languages.map(
                (lang) => ListTile(
                  title: Text(lang.label.tr()),
                  trailing: current == lang.locale
                      ? const Icon(Icons.check_rounded)
                      : null,
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

  // ── Section builders ─────────────────────────────────────────────────────────

  List<_ProfileTile> _preferenceTiles(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    final langValue = context.locale.languageCode == 'zh' ? '简体中文' : 'English';
    return [
      _ProfileTile(
        icon: themeMode == ThemeMode.light
            ? Icons.light_mode_rounded
            : themeMode == ThemeMode.dark
            ? Icons.dark_mode_rounded
            : Icons.brightness_auto_rounded,
        label: 'profile.toggle_dark_mode'.tr(),
        value: themeMode == ThemeMode.light
            ? 'profile.theme_light'.tr()
            : themeMode == ThemeMode.dark
            ? 'profile.theme_dark'.tr()
            : 'profile.theme_system'.tr(),
        onTap: () => _showThemePicker(context, ref, themeMode),
      ),
      _ProfileTile(
        icon: Icons.language_rounded,
        label: 'profile.toggle_language'.tr(),
        value: langValue,
        onTap: () => _showLanguagePicker(context),
      ),
    ];
  }

  List<_ProfileTile> _libraryTiles(
    BuildContext context,
    WidgetRef ref,
    bool isAuthenticated,
  ) {
    return [
      if (isAuthenticated)
        _ProfileTile(
          icon: Icons.person_outline,
          label: 'profile.edit_button'.tr(),
          onTap: () => context.push(AppRoutes.profileEditFull),
        ),
      if (isAuthenticated)
        _ProfileTile(
          icon: Icons.star_outline_rounded,
          label: 'favourites.profile_tile'.tr(),
          onTap: () => context.push(AppRoutes.profileFavourites),
        ),
      _ProfileTile(
        icon: Icons.notifications_outlined,
        label: 'watchlist.profile_tile'.tr(),
        onTap: () => context.push(AppRoutes.profileWatchlist),
      ),
      if (ref.watch(predictionSystemEnabledProvider))
        _ProfileTile(
          icon: Icons.emoji_events_outlined,
          label: 'prediction.league.profile_tile'.tr(),
          onTap: () => context.push(AppRoutes.profilePredictionLeague),
        ),
    ];
  }

  List<_ProfileTile> _legalTiles(BuildContext context) => [
    _ProfileTile(
      icon: Icons.privacy_tip_outlined,
      label: 'profile.privacy_policy'.tr(),
      onTap: () => context.push(
        AppRoutes.privacyPolicy,
        extra: 'profile.privacy_policy'.tr(),
      ),
    ),
    _ProfileTile(
      icon: Icons.description_outlined,
      label: 'profile.terms_of_use'.tr(),
      onTap: () => context.push(
        AppRoutes.userAgreement,
        extra: 'profile.terms_of_use'.tr(),
      ),
    ),
  ];

  List<_ProfileTile> _accountTiles(BuildContext context, WidgetRef ref) => [
    _ProfileTile(
      icon: Icons.logout_rounded,
      label: 'profile.logout'.tr(),
      onTap: () => _confirmLogout(context, ref),
    ),
    _ProfileTile(
      icon: Icons.person_remove_outlined,
      label: 'profile.delete_account'.tr(),
      isDestructive: true,
      onTap: () => _confirmDeleteAccount(context, ref),
    ),
  ];

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated =
        authState.hasValue && (authState.value?.isAuthenticated ?? false);
    final user = authState.value?.user;
    final themeMode = ref.watch(themeModeProvider);
    final colors = context.appColors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHero(isAuthenticated: isAuthenticated, user: user),
          if (!isAuthenticated) ...[
            const SizedBox(height: 24),
            const _GuestCallToAction(),
          ],
          const SizedBox(height: 28),
          _SectionLabel(label: 'profile.section_library'.tr()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _SettingsGroup(
              tiles: _libraryTiles(context, ref, isAuthenticated),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(label: 'profile.section_preferences'.tr()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _SettingsGroup(
              tiles: _preferenceTiles(context, ref, themeMode),
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(label: 'profile.section_legal'.tr()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _SettingsGroup(tiles: _legalTiles(context)),
          ),
          if (isAuthenticated) ...[
            const SizedBox(height: 20),
            _SectionLabel(label: 'profile.section_account'.tr()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _SettingsGroup(tiles: _accountTiles(context, ref)),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                '胜好体育 · v${AppInfo.version}'.toUpperCase(),
                style: AppTextStyles.mono(
                  9,
                ).copyWith(color: colors.text3, letterSpacing: 0.18 * 9),
              ),
            ),
          ),
          SafeArea(top: false, child: const SizedBox()),
        ],
      ),
    );
  }
}

// ── Hero header: gradient photo + overlapping avatar ────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.isAuthenticated, required this.user});

  final bool isAuthenticated;
  final CommunityAuthor? user;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final topPadding = MediaQuery.paddingOf(context).top;
    // Hero section total height:
    // gradient (topPadding + 170) + avatar overflow below gradient (104 - 58 = 46)
    final heroHeight = topPadding + (isAuthenticated ? 216.0 : 170.0);
    final avatarUrl = user?.avatarUrl;
    final nickname = user?.nickname ?? '';

    return SizedBox(
      height: heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: topPadding + 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/shty_bg_profile.jpeg',
                    fit: BoxFit.cover,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [colors.ink.withValues(alpha: 0.35), colors.ink],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAuthenticated)
            Positioned(
              top: topPadding + 112.0, // 170 - 58 overlap
              left: 22,
              right: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ProfileAvatar(avatarUrl: avatarUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        nickname.toUpperCase(),
                        style: AppTextStyles.display(
                          32,
                          context,
                        ).copyWith(color: colors.text),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => context.push(AppRoutes.profileEditFull),
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.ink),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl!,
                        width: 98,
                        height: 98,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Skeletonizer(
                          enabled: true,
                          child: const ColoredBox(color: Colors.grey),
                        ),
                        errorBuilder: (context, url, error) => AvatarFallback(size: 98),
                      )
                    : AvatarFallback(size: 98),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.ink, width: 2.5),
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest mode call-to-action ────────────────────────────────────────────────────

class _GuestCallToAction extends StatelessWidget {
  const _GuestCallToAction();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'profile.guest_mode_title'.tr().toUpperCase(),
            style: AppTextStyles.display(28, context).copyWith(color: colors.text),
          ),
          const SizedBox(height: 8),
          Text(
            'profile.guest_mode_subtitle'.tr(),
            style: context.textTheme.bodyMedium?.copyWith(color: colors.text2),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('auth.register.register'.tr()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.login),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: colors.lineStrong),
                  ),
                  child: Text('auth.login.login'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.display(18, context).copyWith(color: colors.text),
      ),
    );
  }
}

// ── Settings group (bordered card with hairline dividers) ──────────────────────

class _ProfileTile {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;
  final bool isDestructive;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.tiles});

  final List<_ProfileTile> tiles;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.line, width: 0.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Divider(
                height: 0,
                thickness: 0.5,
                color: colors.line,
                indent: 16,
                endIndent: 16,
              ),
            _SettingsTile(data: tiles[i]),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.data});

  final _ProfileTile data;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tileColor = data.isDestructive ? colors.danger : null;

    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon in rounded square
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: data.isDestructive
                    ? colors.danger.withValues(alpha: 0.12)
                    : colors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                data.icon,
                size: 16,
                color: tileColor ?? colors.text2,
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Text(
                data.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: tileColor ?? colors.text,
                ),
              ),
            ),
            // Trailing: value + chevron
            ...[
              if (data.value != null && data.value!.isNotEmpty) ...[
                Text(
                  data.value!,
                  style: AppTextStyles.mono(
                    10,
                  ).copyWith(color: colors.text3, letterSpacing: 0.1 * 10),
                ),
                const SizedBox(width: 4),
              ],
              if (!data.isDestructive)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: colors.text3,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Password confirm dialog content (logic unchanged) ─────────────────────────

class _PasswordConfirmContent extends StatefulWidget {
  const _PasswordConfirmContent({
    required this.controller,
    required this.errorNotifier,
  });

  final TextEditingController controller;
  final ValueNotifier<String?> errorNotifier;

  @override
  State<_PasswordConfirmContent> createState() =>
      _PasswordConfirmContentState();
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
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ],
        );
      },
    );
  }
}
