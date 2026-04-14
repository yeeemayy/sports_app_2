import 'package:easy_localization/easy_localization.dart';

String iceHockeyStatusLabel(int statusId, [String? fallback]) {
  final key = _key(statusId);
  if (key.isNotEmpty) return key.tr();
  return fallback ?? '';
}

String _key(int statusId) {
  switch (statusId) {
    case 1:
      return 'event.ice_hockey.status.pre';
    case 30:
      return 'event.ice_hockey.status.p1';
    case 331:
      return 'event.ice_hockey.status.p1_pause';
    case 31:
      return 'event.ice_hockey.status.p2';
    case 332:
      return 'event.ice_hockey.status.p2_pause';
    case 32:
      return 'event.ice_hockey.status.p3';
    case 100:
      return 'event.ice_hockey.status.ft';
    case 6:
      return 'event.ice_hockey.status.aw_ot';
    case 10:
      return 'event.ice_hockey.status.ot';
    case 105:
      return 'event.ice_hockey.status.aft_ot';
    case 8:
      return 'event.ice_hockey.status.aw_pen';
    case 13:
      return 'event.ice_hockey.status.pen';
    case 110:
      return 'event.ice_hockey.status.aft_pen';
    case 14:
      return 'event.ice_hockey.status.pst';
    case 15:
      return 'event.ice_hockey.status.dly';
    case 16:
      return 'event.ice_hockey.status.can';
    case 17:
      return 'event.ice_hockey.status.int';
    case 19:
      return 'event.ice_hockey.status.sus';
    case 99:
      return 'event.ice_hockey.status.tbd';
    default:
      return '';
  }
}
