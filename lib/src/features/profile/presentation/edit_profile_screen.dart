import 'dart:io';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
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
              leading: const Icon(Icons.camera_alt),
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
    final image = await ImagePicker().pickImage(source: source, imageQuality: 85);
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
          .updateProfile(nickname: _nicknameController.text.trim(), avatarUrl: avatarUrl);
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
        context.showErrorDialog(title: 'profile.edit_error_title'.tr(), error: e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value?.user;
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      appBar: AppBar(title: Text('profile.edit_title'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipOval(
                      child: _pickedImage != null
                          ? Image.file(
                              File(_pickedImage!.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : (avatarUrl != null && avatarUrl.isNotEmpty
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
                                : AvatarFallback()),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'profile.edit_change_avatar'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                textEditingController: _nicknameController,
                label: 'profile.edit_nickname_label'.tr(),
                hintText: 'profile.edit_nickname_hint'.tr(),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'auth.validation.nickname_required'.tr()
                    : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('profile.edit_save'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
