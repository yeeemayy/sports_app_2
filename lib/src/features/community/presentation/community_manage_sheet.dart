import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/community_auth_guard.dart';
import '../../../shared_widgets/custom_status_dialog.dart';
import '../domain/models/community_post.dart';
import 'community_report_sheet.dart';
import 'providers/community_providers.dart';

/// Mirrors sports_forum's `post_edit_sheet.dart` / `post_manage_sheet.dart`:
/// a bottom sheet offering Edit + Delete for the post's own author, or
/// Report for anyone else, rather than a dropdown menu.
Future<void> showCommunityPostManageSheet(
  BuildContext rootContext, {
  required WidgetRef ref,
  required CommunityPost post,
  required bool isOwner,
  required VoidCallback onDeleted,
}) {
  return showModalBottomSheet<void>(
    context: rootContext,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: BoxDecoration(
        color: rootContext.appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: rootContext.appColors.surface2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            if (isOwner) ...[
              _SheetRow(
                icon: Icons.edit_outlined,
                labelKey: 'community.edit',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  rootContext.push('/community/create', extra: post);
                },
              ),
              Divider(height: 1, color: rootContext.appColors.surface2),
              _SheetRow(
                icon: Icons.delete_outline,
                labelKey: 'community.delete',
                color: rootContext.appColors.danger,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmDelete(rootContext, ref: ref, post: post, onDeleted: onDeleted);
                },
              ),
            ] else
              _SheetRow(
                icon: Icons.flag_outlined,
                labelKey: 'community.report',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (ensureCommunityLoggedIn(rootContext, ref)) {
                    showCommunityReportSheet(rootContext, type: 'post', id: post.id);
                  }
                },
              ),
          ],
        ),
      ),
    ),
  );
}

void _confirmDelete(
  BuildContext rootContext, {
  required WidgetRef ref,
  required CommunityPost post,
  required VoidCallback onDeleted,
}) {
  showCustomStatusDialog(
    context: rootContext,
    dialogType: DialogType.custom,
    overrideIcon: Icons.delete_outline,
    overrideIconBackgroundColor: rootContext.appColors.danger,
    title: 'community.delete_confirm_title'.tr(),
    buttonText: 'community.delete'.tr(),
    buttonBackgroundColor: rootContext.appColors.danger,
    onButtonPressed: () async {
      rootContext.pop();
      final locale = rootContext.locale.languageCode == 'zh' ? 'cn' : 'en';
      await ref.read(communityRepositoryProvider).deletePost(locale, post.id);
      ref.invalidate(communityFeedProvider);
      ref.invalidate(communityMyPostsProvider);
      onDeleted();
    },
    secondaryButton: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        onPressed: () => Navigator.of(rootContext).pop(),
        child: Text('common.cancel'.tr()),
      ),
    ),
  );
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.labelKey, required this.onTap, this.color});

  final IconData icon;
  final String labelKey;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? DefaultTextStyle.of(context).style.color ?? Colors.black87;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Text(labelKey.tr(), style: TextStyle(fontSize: 15, color: effectiveColor)),
          ],
        ),
      ),
    );
  }
}
