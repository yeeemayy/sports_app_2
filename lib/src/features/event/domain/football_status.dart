import 'package:easy_localization/easy_localization.dart';

String footballStatusLabel(int statusId, [String? fallback]) {
  final key = _key(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _key(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.football.status.not_started';
    case 2:
      return 'event.football.status.first_half';
    case 3:
      return 'event.football.status.half_time';
    case 4:
      return 'event.football.status.second_half';
    case 5:
    case 6:
      return 'event.football.status.overtime';
    case 7:
      return 'event.football.status.penalty';
    case 8:
      return 'event.football.status.finished';
    case 9:
      return 'event.football.status.delay';
    case 10:
      return 'event.football.status.interrupt';
    case 11:
      return 'event.football.status.cut_in_half';
    case 12:
      return 'event.football.status.cancelled';
    case 13:
      return 'event.football.status.tbd';
    default:
      return '';
  }
}

const footballLiveStatuses = {2, 3, 4, 5, 6, 7};

bool footballIsLive(int statusId) => footballLiveStatuses.contains(statusId);
