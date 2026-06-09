import 'package:easy_localization/easy_localization.dart';

String cricketStatusLabel(int statusId, [String? fallback]) {
  final key = _key(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _key(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.cricket.status.pre';
    case 2:
      return 'event.cricket.status.started';
    case 3:
      return 'event.cricket.status.in_progress';
    case 532:
      return 'event.cricket.status.h1_home';
    case 533:
      return 'event.cricket.status.h1_away';
    case 534:
      return 'event.cricket.status.h2_home';
    case 535:
      return 'event.cricket.status.h2_away';
    case 536:
      return 'event.cricket.status.aw_super';
    case 537:
      return 'event.cricket.status.super_home';
    case 538:
      return 'event.cricket.status.super_away';
    case 539:
      return 'event.cricket.status.aft_super';
    case 540:
      return 'event.cricket.status.inn_break';
    case 541:
      return 'event.cricket.status.super_break';
    case 542:
      return 'event.cricket.status.lunch';
    case 543:
      return 'event.cricket.status.tea';
    case 544:
      return 'event.cricket.status.day_end';
    case 545:
      return 'event.cricket.status.water';
    case 100:
      return 'event.cricket.status.ft';
    case 14:
      return 'event.cricket.status.pst';
    case 15:
      return 'event.cricket.status.dly';
    case 16:
      return 'event.cricket.status.can';
    case 17:
      return 'event.cricket.status.int';
    case 19:
      return 'event.cricket.status.sus';
    case 99:
      return 'event.cricket.status.tbd';
    default:
      return '';
  }
}

const cricketLiveStatuses = {2, 3, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545};

bool cricketIsLive(int statusId) => cricketLiveStatuses.contains(statusId);
