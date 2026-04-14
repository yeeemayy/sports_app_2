import 'package:easy_localization/easy_localization.dart';

String amFootballStatusLabel(int statusId, [String? fallback]) {
  final key = _key(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _key(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.am_football.status.pre';
    case 44:
      return 'event.am_football.status.q1';
    case 331:
      return 'event.am_football.status.q1_pause';
    case 45:
      return 'event.am_football.status.q2';
    case 332:
      return 'event.am_football.status.q2_pause';
    case 46:
      return 'event.am_football.status.q3';
    case 333:
      return 'event.am_football.status.q3_pause';
    case 47:
      return 'event.am_football.status.q4';
    case 100:
      return 'event.am_football.status.ft';
    case 6:
      return 'event.am_football.status.aw_ot';
    case 10:
      return 'event.am_football.status.ot';
    case 105:
      return 'event.am_football.status.aft_ot';
    case 14:
      return 'event.am_football.status.pst';
    case 15:
      return 'event.am_football.status.dly';
    case 16:
      return 'event.am_football.status.can';
    case 17:
      return 'event.am_football.status.int';
    case 19:
      return 'event.am_football.status.sus';
    case 99:
      return 'event.am_football.status.tbd';
    default:
      return '';
  }
}
