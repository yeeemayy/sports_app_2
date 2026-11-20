import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../extensions/context_extensions.dart';
import '../../../shared_widgets/custom_status_dialog.dart';
import '../domain/models/community_post.dart';
import 'community_header_bar.dart';
import 'providers/community_providers.dart';

const _kMaxImages = 3;

/// Reuses one screen for both create and edit, like sports_forum's
/// `CreatePostScreen(editPost: Post?)`. Category/hashtag selection is plain
/// inline chips rather than forum's bottom sheets — same functionality
/// (multi-select), less UI ceremony, matching this feature's smaller scope.
class CommunityCreatePostScreen extends ConsumerStatefulWidget {
  const CommunityCreatePostScreen({super.key, this.editPost});

  final CommunityPost? editPost;

  @override
  ConsumerState<CommunityCreatePostScreen> createState() => _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState extends ConsumerState<CommunityCreatePostScreen> {
  late final _contentController = TextEditingController(text: widget.editPost?.content ?? '');
  final _tagController = TextEditingController();
  late final List<String> _images = List.of(widget.editPost?.images ?? const []);
  late final Set<int> _selectedCategoryIds =
      widget.editPost?.categories.map((c) => c.id).toSet() ?? {};
  late final List<String> _hashtags = List.of(widget.editPost?.hashtags ?? const []);
  bool _posting = false;

  bool get _isEditing => widget.editPost != null;

  String _locale(BuildContext context) => context.locale.languageCode == 'zh' ? 'cn' : 'en';

  Future<void> _pickImage() async {
    if (_images.length >= _kMaxImages) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _images.add(picked.path));
  }

  void _addCustomTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty || _hashtags.contains(tag)) return;
    setState(() {
      _hashtags.add(tag);
      _tagController.clear();
    });
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    setState(() => _posting = true);
    final locale = _locale(context);
    final repo = ref.read(communityRepositoryProvider);
    try {
      if (_isEditing) {
        await repo.updatePost(
          locale,
          widget.editPost!.id,
          content: content,
          images: _images,
          categoryIds: _selectedCategoryIds.toList(),
          hashtags: _hashtags,
        );
        ref.invalidate(communityPostDetailProvider((locale: locale, id: widget.editPost!.id)));
      } else {
        await repo.createPost(
          locale,
          content: content,
          images: _images,
          categoryIds: _selectedCategoryIds.toList(),
          hashtags: _hashtags,
        );
      }
      ref.invalidate(communityFeedProvider);
      ref.invalidate(communityMyPostsProvider);
      if (mounted) {
        await showCustomStatusDialog(
          context: context,
          dialogType: DialogType.success,
          title: (_isEditing ? 'community.post_updated' : 'community.post_created').tr(),
          buttonText: 'common.got_it'.tr(),
          onButtonPressed: () {
            context.pop();
            context.pop();
          },
        );
      }
    } catch (e) {
      if (mounted) context.showErrorDialog(title: 'common.error_generic'.tr(), error: e);
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = _locale(context);
    final categoriesAsync = ref.watch(communityCategoriesProvider(locale));
    final trendingAsync = ref.watch(communityHashtagsProvider(locale));

    return Scaffold(
      appBar: communityHeaderBar(
        context,
        title: (_isEditing ? 'community.edit_title' : 'community.create_title').tr(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            TextField(
              controller: _contentController,
              autofocus: !_isEditing,
              minLines: 6,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: 'community.create_hint'.tr(),
                filled: true,
                fillColor: context.appColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            _ImagePickerRow(images: _images, onPick: _pickImage, onRemove: (i) => setState(() => _images.removeAt(i))),
            const SizedBox(height: 20),
            Text('community.categories_label'.tr(), style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const SizedBox(height: 32),
              error: (e, st) => const SizedBox.shrink(),
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categories)
                    _SelectableChip(
                      label: c.name,
                      selected: _selectedCategoryIds.contains(c.id),
                      onTap: () => setState(() {
                        if (_selectedCategoryIds.contains(c.id)) {
                          _selectedCategoryIds.remove(c.id);
                        } else {
                          _selectedCategoryIds.add(c.id);
                        }
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('community.topics_label'.tr(), style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text)),
            const SizedBox(height: 8),
            trendingAsync.when(
              loading: () => const SizedBox(height: 32),
              error: (e, st) => const SizedBox.shrink(),
              data: (trending) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hashtag in trending)
                    _SelectableChip(
                      label: '#${hashtag.name}',
                      selected: _hashtags.contains(hashtag.name),
                      onTap: () => setState(() {
                        if (_hashtags.contains(hashtag.name)) {
                          _hashtags.remove(hashtag.name);
                        } else {
                          _hashtags.add(hashtag.name);
                        }
                      }),
                    ),
                  for (final tag in _hashtags.where((t) => !trending.any((h) => h.name == t)))
                    _SelectableChip(
                      label: '#$tag',
                      selected: true,
                      onTap: () => setState(() => _hashtags.remove(tag)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'community.add_topic_hint'.tr(),
                      isDense: true,
                      filled: true,
                      fillColor: context.appColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _addCustomTag(),
                  ),
                ),
                IconButton(icon: Icon(Icons.add, color: context.appColors.text), onPressed: _addCustomTag),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.text,
                foregroundColor: context.appColors.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _posting ? null : _submit,
              child: _posting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text((_isEditing ? 'common.save' : 'community.post_button').tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? context.appColors.accent : context.appColors.surface,
        ),
        child: Text(
          label,
          style: AppTextStyles.body(13).copyWith(fontWeight: FontWeight.w600, color: context.appColors.text).copyWith(color: selected ? Colors.white : context.appColors.text2),
        ),
      ),
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  const _ImagePickerRow({required this.images, required this.onPick, required this.onRemove});

  final List<String> images;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        for (var i = 0; i < images.length; i++) _ImageTile(path: images[i], onRemove: () => onRemove(i)),
        if (images.length < _kMaxImages)
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.appColors.text3.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 24, color: context.appColors.text3),
                  const SizedBox(height: 4),
                  Text('community.add_image'.tr(), style: TextStyle(fontSize: 11, color: context.appColors.text3)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http');
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isNetwork
                ? Image.network(path, width: 88, height: 88, fit: BoxFit.cover)
                : Image.file(File(path), width: 88, height: 88, fit: BoxFit.cover),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
