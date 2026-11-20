import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../extensions/context_extensions.dart';
import '../../../shared_widgets/custom_status_dialog.dart';
import 'providers/community_providers.dart';

const _kReportReasons = ['spam', 'abuse', 'misinformation', 'inappropriate', 'other'];

/// `type` is one of `post`, `comment`, `user` — sports_forum's unified
/// `/reports` endpoint. `rootContext` (the screen that opened the sheet) is
/// used for the follow-up success/error dialog, since the sheet's own
/// context is gone once it's popped.
Future<void> showCommunityReportSheet(
  BuildContext rootContext, {
  required String type,
  required int id,
}) {
  return showModalBottomSheet<void>(
    context: rootContext,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => _ReportSheetBody(type: type, id: id, rootContext: rootContext),
  );
}

class _ReportSheetBody extends ConsumerStatefulWidget {
  const _ReportSheetBody({required this.type, required this.id, required this.rootContext});

  final String type;
  final int id;
  final BuildContext rootContext;

  @override
  ConsumerState<_ReportSheetBody> createState() => _ReportSheetBodyState();
}

class _ReportSheetBodyState extends ConsumerState<_ReportSheetBody> {
  String _reason = _kReportReasons.first;
  final _detailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await ref.read(communityRepositoryProvider).report(
            type: widget.type,
            id: widget.id,
            reason: _reason,
            detail: _detailController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
      if (widget.rootContext.mounted) {
        await showCustomStatusDialog(
          context: widget.rootContext,
          dialogType: DialogType.success,
          title: 'community.report_submitted'.tr(),
          buttonText: 'common.got_it'.tr(),
          onButtonPressed: () => Navigator.of(widget.rootContext).pop(),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (widget.rootContext.mounted) {
        widget.rootContext.showErrorDialog(title: 'common.error_generic'.tr(), error: e);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text('community.report_title'.tr(), style: AppTextStyles.display(18, context).copyWith(color: context.appColors.text, height: 1)),
            ),
            RadioGroup<String>(
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v!),
              child: Column(
                children: [
                  for (final reason in _kReportReasons)
                    RadioListTile<String>(
                      value: reason,
                      title: Text('community.report_reason_$reason'.tr(), style: AppTextStyles.body(14).copyWith(color: context.appColors.text)),
                      activeColor: context.appColors.text,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _detailController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'community.report_detail_hint'.tr(),
                  filled: true,
                  fillColor: context.appColors.surface2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.appColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('community.report_submit'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
