import 'package:easy_localization/easy_localization.dart';

String volleyballStatusLabel(int statusId, [String? fallback]) {
  final key = _key(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _key(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.volleyball.status.pre';
    case 432:
      return 'event.volleyball.status.s1';
    case 434:
      return 'event.volleyball.status.s2';
    case 436:
      return 'event.volleyball.status.s3';
    case 438:
      return 'event.volleyball.status.s4';
    case 440:
      return 'event.volleyball.status.s5';
    case 100:
      return 'event.volleyball.status.ft';
    case 14:
      return 'event.volleyball.status.pst';
    case 15:
      return 'event.volleyball.status.dly';
    case 16:
      return 'event.volleyball.status.can';
    case 17:
      return 'event.volleyball.status.int';
    case 19:
      return 'event.volleyball.status.sus';
    case 99:
      return 'event.volleyball.status.tbd';
    default:
      return '';
  }
}

const volleyballLiveStatuses = {432, 434, 436, 438, 440};

bool volleyballIsLive(int statusId) => volleyballLiveStatuses.contains(statusId);
