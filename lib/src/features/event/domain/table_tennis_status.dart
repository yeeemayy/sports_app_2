import 'package:easy_localization/easy_localization.dart';

/// Returns the localised display label for a table tennis match [statusId].
///
/// Falls back to [fallback] when no registered label exists for the given id.
String tableTennisStatusLabel(int statusId, [String? fallback]) {
  final key = _tableTennisStatusKey(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _tableTennisStatusKey(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.table_tennis.status.pre';
    case 3:
      return 'event.table_tennis.status.live';
    case 51:
      return 'event.table_tennis.status.s1';
    case 331:
      return 'event.table_tennis.status.p1';
    case 52:
      return 'event.table_tennis.status.s2';
    case 332:
      return 'event.table_tennis.status.p2';
    case 53:
      return 'event.table_tennis.status.s3';
    case 333:
      return 'event.table_tennis.status.p3';
    case 54:
      return 'event.table_tennis.status.s4';
    case 334:
      return 'event.table_tennis.status.p4';
    case 55:
      return 'event.table_tennis.status.s5';
    case 335:
      return 'event.table_tennis.status.p5';
    case 472:
      return 'event.table_tennis.status.s6';
    case 336:
      return 'event.table_tennis.status.p6';
    case 473:
      return 'event.table_tennis.status.s7';
    case 100:
      return 'event.table_tennis.status.ft';
    case 20:
    case 22:
    case 23:
      return 'event.table_tennis.status.wo';
    case 21:
    case 24:
    case 25:
      return 'event.table_tennis.status.ret';
    case 26:
    case 27:
      return 'event.table_tennis.status.def';
    case 14:
      return 'event.table_tennis.status.pst';
    case 15:
      return 'event.table_tennis.status.dly';
    case 16:
      return 'event.table_tennis.status.can';
    case 17:
      return 'event.table_tennis.status.int';
    case 19:
      return 'event.table_tennis.status.sus';
    case 99:
      return 'event.table_tennis.status.tbd';
    default:
      return '';
  }
}

const tableTennisLiveStatuses = {3, 51, 52, 53, 54, 55, 472, 473};

bool tableTennisIsLive(int statusId) => tableTennisLiveStatuses.contains(statusId);
