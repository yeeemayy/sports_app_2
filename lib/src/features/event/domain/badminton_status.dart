import 'package:easy_localization/easy_localization.dart';

/// Returns the localised display label for a badminton match [statusId].
///
/// Falls back to [fallback] when no registered label exists for the given id.
String badmintonStatusLabel(int statusId, [String? fallback]) {
  final key = _badmintonStatusKey(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _badmintonStatusKey(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.badminton.status.pre';
    case 3:
      return 'event.badminton.status.live';
    case 51:
      return 'event.badminton.status.s1';
    case 331:
      return 'event.badminton.status.p1';
    case 52:
      return 'event.badminton.status.s2';
    case 332:
      return 'event.badminton.status.p2';
    case 53:
      return 'event.badminton.status.s3';
    case 333:
      return 'event.badminton.status.p3';
    case 54:
      return 'event.badminton.status.s4';
    case 334:
      return 'event.badminton.status.p4';
    case 55:
      return 'event.badminton.status.s5';
    case 100:
      return 'event.badminton.status.ft';
    case 20:
    case 22:
    case 23:
      return 'event.badminton.status.wo';
    case 21:
    case 24:
    case 25:
      return 'event.badminton.status.ret';
    case 26:
    case 27:
      return 'event.badminton.status.def';
    case 14:
      return 'event.badminton.status.pst';
    case 15:
      return 'event.badminton.status.dly';
    case 16:
      return 'event.badminton.status.can';
    case 17:
      return 'event.badminton.status.int';
    case 19:
      return 'event.badminton.status.sus';
    case 99:
      return 'event.badminton.status.tbd';
    default:
      return '';
  }
}
