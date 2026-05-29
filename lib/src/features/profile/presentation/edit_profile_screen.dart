import 'dart:io';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sports_app/src/features/auth/data/auth_repository.dart';
import 'package:sports_app/src/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sports_app/src/shared_widgets/avatar.dart';
import 'package:sports_app/src/extensions/context_extensions.dart';
import 'package:sports_app/src/shared_widgets/custom_status_dialog.dart';
import 'package:sports_app/src/shared_widgets/custom_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  XFile? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).value?.user;
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text('profile.avatar_take_photo'.tr()),
              onTap: () => context.pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('profile.avatar_choose_gallery'.tr()),
              onTap: () => context.pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(authRepositoryProvider.notifier);
      String? avatarUrl;
      if (_pickedImage != null) {
        avatarUrl = await repo.uploadAvatar(_pickedImage!.path);
        debugPrint(avatarUrl);
      }
      await ref
          .read(authNotifierProvider.notifier)
          .updateProfile(
            nickname: _nicknameController.text.trim(),
            avatarUrl: avatarUrl,
          );
      if (mounted) {
        await showCustomStatusDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'profile.edit_success'.tr(),
          buttonText: 'common.ok'.tr(),
          onButtonPressed: () {
            context.pop();
            context.pop();
          },
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorDialog(
          title: 'profile.edit_error_title'.tr(),
          error: e,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value?.user;
    final avatarUrl = user?.avatarUrl;
    final colors = context.appColors;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: colors.ink,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // ── Arena-style header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: topPadding + 160,
                child: Stack(
                  children: [
                    // Gradient background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [colors.surface2, colors.ink],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Accent glow
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      colors.accent.withValues(alpha: 0.18),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Back button + title
                    Positioned(
                      top: topPadding + 8,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.lineStrong,
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: colors.text,
                                size: 16,
                              ),
                            ),
                          ),
                          // Title
                          Expanded(
                            child: Center(
                              child: Text(
                                'profile.edit_title'.tr().toUpperCase(),
                                style: AppTextStyles.display(
                                  18,
                                  context,
                                ).copyWith(color: colors.text),
                              ),
                            ),
                          ),
                          // Balance spacer
                          const SizedBox(width: 38),
                        ],
                      ),
                    ),

                    // Avatar centred at the bottom of the header
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.ink,
                                  ),
                                  child: ClipOval(
                                    child: _pickedImage != null
                                        ? Image.file(
                                            File(_pickedImage!.path),
                                            width: 94,
                                            height: 94,
                                            fit: BoxFit.cover,
                                          )
                                        : (avatarUrl != null &&
                                                  avatarUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: avatarUrl,
                                                  width: 94,
                                                  height: 94,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Skeletonizer(
                                                        enabled: true,
                                                        child: const ColoredBox(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                  errorBuilder:
                                                      (context, url, error) =>
                                                          AvatarFallback(
                                                            size: 94,
                                                          ),
                                                )
                                              : AvatarFallback(size: 94)),
                                  ),
                                ),
                                // Camera badge
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: colors.accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.ink,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form content ─────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Change avatar hint
                  Center(
                    child: Text(
                      'profile.edit_change_avatar'.tr(),
                      style: AppTextStyles.mono(
                        10,
                      ).copyWith(color: colors.text3, letterSpacing: 0.14 * 10),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nickname field
                  CustomTextField(
                    textEditingController: _nicknameController,
                    label: 'profile.edit_nickname_label'.tr(),
                    hintText: 'profile.edit_nickname_hint'.tr(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'auth.validation.nickname_required'.tr()
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: colors.accent.withValues(
                          alpha: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: AppTextStyles.display(14, context),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('profile.edit_save'.tr().toUpperCase()),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
