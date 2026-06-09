import 'package:easy_localization/easy_localization.dart';

/// Returns the localised display label for a tennis match [statusId].
///
/// Falls back to [fallback] when no registered label exists for the given id.
String tennisStatusLabel(int statusId, [String? fallback]) {
  final key = _tennisStatusKey(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _tennisStatusKey(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.tennis.status.pre';
    case 3:
      return 'event.tennis.status.live';
    case 51:
      return 'event.tennis.status.s1';
    case 52:
      return 'event.tennis.status.s2';
    case 53:
      return 'event.tennis.status.s3';
    case 54:
      return 'event.tennis.status.s4';
    case 55:
      return 'event.tennis.status.s5';
    case 100:
      return 'event.tennis.status.ft';
    case 20:
    case 22:
    case 23:
      return 'event.tennis.status.wo';
    case 21:
    case 24:
    case 25:
      return 'event.tennis.status.ret';
    case 26:
    case 27:
      return 'event.tennis.status.def';
    case 14:
      return 'event.tennis.status.pst';
    case 15:
      return 'event.tennis.status.dly';
    case 16:
      return 'event.tennis.status.can';
    case 17:
      return 'event.tennis.status.int';
    case 18:
      return 'event.tennis.status.sus';
    case 99:
      return 'event.tennis.status.tbd';
    default:
      return '';
  }
}

const tennisLiveStatuses = {3, 51, 52, 53, 54, 55};

bool tennisIsLive(int statusId) => tennisLiveStatuses.contains(statusId);
