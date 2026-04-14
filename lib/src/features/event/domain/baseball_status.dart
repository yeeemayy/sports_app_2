import 'package:easy_localization/easy_localization.dart';

/// Returns a compact label for the baseball status badge on match cards.
String baseballStatusLabel(int statusId) {
  final labels = <int, String>{
    1: 'event.baseball.status.not_started'.tr(),
    100: 'event.baseball.status.end'.tr(),
    14: 'event.baseball.status.pst'.tr(),
    15: 'event.baseball.status.dly'.tr(),
    16: 'event.baseball.status.can'.tr(),
    17: 'event.baseball.status.sus'.tr(),
    19: 'event.baseball.status.mid'.tr(),
    99: 'event.baseball.status.tbd'.tr(),
    // TOP half of inning (▲)
    432: '1▲', 434: '2▲', 436: '3▲', 438: '4▲', 440: '5▲',
    412: '6▲', 414: '7▲', 416: '8▲', 418: '9▲', 420: 'EI▲',
    // BOTTOM half of inning (▼)
    433: '1▼', 435: '2▼', 437: '3▼', 439: '4▼', 411: '5▼',
    413: '6▼', 415: '7▼', 417: '8▼', 419: '9▼', 421: 'EI▼',
    // Breaks between half-innings
    452: '1-', 453: '2-', 454: '2-', 455: '3-', 456: '3-', 457: '4-',
    458: '4-', 459: '5-', 460: '5-', 461: '6-', 462: '6-', 463: '7-',
    464: '7-', 465: '8-', 466: '8-', 467: '9-', 468: '9-', 469: 'EI-', 470: 'EI-',
  };
  return labels[statusId] ?? '';
}

bool baseballIsLive(int statusId) {
  if (statusId == 1 || statusId == 0 || statusId == 100) return false;
  if (statusId >= 14 && statusId <= 19) return false;
  if (statusId == 99) return false;
  return statusId >= 100 ? false : statusId != 1;
}

/// The set of status IDs that represent an ongoing game.
const baseballLiveStatuses = {
  411,
  412,
  413,
  414,
  415,
  416,
  417,
  418,
  419,
  420,
  421,
  432,
  433,
  434,
  435,
  436,
  437,
  438,
  439,
  440,
  452,
  453,
  454,
  455,
  456,
  457,
  458,
  459,
  460,
  461,
  462,
  463,
  464,
  465,
  466,
  467,
  468,
  469,
  470,
};
