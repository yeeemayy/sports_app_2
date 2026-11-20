import 'package:easy_localization/easy_localization.dart';

/// Formats Community post/comment timestamps as relative "time ago" labels.
class DateFormatting {
  DateFormatting._();

  /// "time ago" for a past timestamp, e.g. "2h ago". Falls back to a plain
  /// date once past a week.
  static String relativeLabel(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'community.relative_time.just_now'.tr();
    if (diff.inHours < 1) {
      return 'community.relative_time.minutes'.tr(namedArgs: {'n': '${diff.inMinutes}'});
    }
    if (diff.inDays < 1) {
      return 'community.relative_time.hours'.tr(namedArgs: {'n': '${diff.inHours}'});
    }
    if (diff.inDays < 7) {
      return 'community.relative_time.days'.tr(namedArgs: {'n': '${diff.inDays}'});
    }
    final d = dateTime;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
