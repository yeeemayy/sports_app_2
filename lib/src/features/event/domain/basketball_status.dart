import 'package:easy_localization/easy_localization.dart';

String basketballStatusLabel(int statusId, [String? fallback]) {
  final key = _key(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _key(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.basketball.period.not_started';
    case 2:
      return 'event.basketball.period.q1';
    case 3:
      return 'event.basketball.period.q1_over';
    case 4:
      return 'event.basketball.period.q2';
    case 5:
      return 'event.basketball.period.q2_over';
    case 6:
      return 'event.basketball.period.q3';
    case 7:
      return 'event.basketball.period.q3_over';
    case 8:
      return 'event.basketball.period.q4';
    case 9:
      return 'event.basketball.period.ot';
    case 10:
      return 'event.basketball.period.end';
    case 11:
      return 'event.basketball.period.interrupt';
    case 12:
      return 'event.basketball.period.cancel';
    case 13:
      return 'event.basketball.period.extension';
    case 14:
      return 'event.basketball.period.half';
    default:
      return '';
  }
}

const basketballLiveStatuses = {2, 4, 6, 8, 9, 13};

bool basketballIsLive(int statusId) => basketballLiveStatuses.contains(statusId);
