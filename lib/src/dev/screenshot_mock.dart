// Toggle to true to return placeholder data for screenshot capture.
// Set back to false before shipping.

import 'package:sports_app/src/features/event/domain/models/football_lineup.dart';
import 'package:sports_app/src/features/event/domain/models/football_match.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_detail.dart';
import 'package:sports_app/src/features/event/domain/models/football_match_events.dart';
import 'package:sports_app/src/features/event/domain/models/sport_match.dart';

const kScreenshotMode = false;

// ─── Match lists ──────────────────────────────────────────────────────────────

FootballMatch _match({
  required String id,
  required int statusId,
  required String time,
  required String home,
  required String away,
  String homeScore = '-',
  String awayScore = '-',
  String? htHome,
  String? htAway,
  String league = '某某联赛',
  int? counterTiming,
}) => FootballMatch(
  id: id,
  statusId: statusId,
  matchTimeSim: time,
  homeName: home,
  homeLogo: '',
  homeScore: homeScore,
  awayName: away,
  awayLogo: '',
  awayScore: awayScore,
  leagueName: league,
  leagueLogo: '',
  htHomeScore: htHome,
  htAwayScore: htAway,
  counterTiming: counterTiming,
);

int _nowMinus(int minutes) =>
    (DateTime.now().millisecondsSinceEpoch ~/ 1000) - minutes * 60;

// Hot tab — mixture of statuses
final mockHotMatches = <SportMatch>[
  _match(id: 'mock-hot-1', statusId: 1, time: '20:00', home: '主队甲', away: '客队甲', league: '联赛甲'),
  _match(
    id: 'mock-hot-2',
    statusId: 2,
    time: '19:00',
    home: '主队乙',
    away: '客队乙',
    homeScore: '1',
    awayScore: '0',
    league: '联赛乙',
    counterTiming: _nowMinus(20),
  ),
  _match(
    id: 'mock-hot-3',
    statusId: 8,
    time: '昨天',
    home: '主队丙',
    away: '客队丙',
    homeScore: '2',
    awayScore: '2',
    htHome: '1',
    htAway: '0',
    league: '联赛丙',
  ),
  _match(id: 'mock-hot-4', statusId: 1, time: '21:45', home: '主队丁', away: '客队丁', league: '联赛甲'),
  _match(
    id: 'mock-hot-5',
    statusId: 4,
    time: '18:00',
    home: '主队戊',
    away: '客队戊',
    homeScore: '0',
    awayScore: '1',
    htHome: '0',
    htAway: '1',
    league: '联赛丙',
    counterTiming: _nowMinus(55),
  ),
  _match(
    id: 'mock-hot-6',
    statusId: 3,
    time: '17:30',
    home: '主队己',
    away: '客队己',
    homeScore: '1',
    awayScore: '1',
    htHome: '1',
    htAway: '1',
    league: '联赛乙',
  ),
  _match(id: 'mock-hot-7', statusId: 1, time: '22:00', home: '主队庚', away: '客队庚', league: '联赛丁'),
  _match(
    id: 'mock-hot-8',
    statusId: 2,
    time: '20:30',
    home: '主队辛',
    away: '客队辛',
    homeScore: '2',
    awayScore: '0',
    league: '联赛丁',
    counterTiming: _nowMinus(35),
  ),
  _match(
    id: 'mock-hot-9',
    statusId: 8,
    time: '昨天',
    home: '主队壬',
    away: '客队壬',
    homeScore: '1',
    awayScore: '3',
    htHome: '0',
    htAway: '1',
    league: '联赛甲',
  ),
  _match(id: 'mock-hot-10', statusId: 1, time: '23:00', home: '主队癸', away: '客队癸', league: '联赛丙'),
];

// Live / Ongoing tab
final mockLiveMatches = <SportMatch>[
  _match(
    id: 'mock-live-1',
    statusId: 2,
    time: '20:00',
    home: '主队甲',
    away: '客队甲',
    homeScore: '0',
    awayScore: '0',
    league: '联赛甲',
    counterTiming: _nowMinus(12),
  ),
  _match(
    id: 'mock-live-2',
    statusId: 3,
    time: '18:00',
    home: '主队乙',
    away: '客队乙',
    homeScore: '1',
    awayScore: '1',
    htHome: '1',
    htAway: '1',
    league: '联赛乙',
  ),
  _match(
    id: 'mock-live-3',
    statusId: 4,
    time: '16:00',
    home: '主队丙',
    away: '客队丙',
    homeScore: '2',
    awayScore: '1',
    htHome: '1',
    htAway: '0',
    league: '联赛丙',
    counterTiming: _nowMinus(58),
  ),
];

// Finished / End tab
final mockFinishedMatches = <SportMatch>[
  _match(
    id: 'mock-end-1',
    statusId: 8,
    time: '20:00',
    home: '主队甲',
    away: '客队甲',
    homeScore: '3',
    awayScore: '1',
    htHome: '2',
    htAway: '0',
    league: '联赛甲',
  ),
  _match(
    id: 'mock-end-2',
    statusId: 8,
    time: '18:00',
    home: '主队乙',
    away: '客队乙',
    homeScore: '0',
    awayScore: '0',
    htHome: '0',
    htAway: '0',
    league: '联赛乙',
  ),
  _match(
    id: 'mock-end-3',
    statusId: 8,
    time: '16:00',
    home: '主队丙',
    away: '客队丙',
    homeScore: '2',
    awayScore: '3',
    htHome: '1',
    htAway: '2',
    league: '联赛丙',
  ),
  _match(
    id: 'mock-end-4',
    statusId: 8,
    time: '14:00',
    home: '主队丁',
    away: '客队丁',
    homeScore: '1',
    awayScore: '1',
    htHome: '0',
    htAway: '1',
    league: '联赛甲',
  ),
];

// ─── Match detail ─────────────────────────────────────────────────────────────

final mockMatchDetail = FootballMatchDetail(
  id: 'mock-detail',
  statusId: 8,
  matchTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  homeScores: const [3, 1],
  awayScores: const [1, 0],
  homeInfo: const FootballTeamDetailInfo(
    enName: 'Home Team',
    cnName: '主队甲',
    logo: '',
    score: 3,
    halfTimeScore: 2,
    redCards: 0,
    yellowCards: 1,
    cornerScore: 5,
  ),
  awayInfo: const FootballTeamDetailInfo(
    enName: 'Away Team',
    cnName: '客队甲',
    logo: '',
    score: 1,
    halfTimeScore: 0,
    redCards: 0,
    yellowCards: 2,
    cornerScore: 3,
  ),
  leagueInfo: const FootballLeagueDetailInfo(
    enName: 'League A',
    cnName: '联赛甲',
    logo: '',
  ),
);

// ─── Match events ─────────────────────────────────────────────────────────────

const mockMatchEvents = FootballMatchEvents(
  id: 'mock-events',
  kickoffTimestamp: null,
  incidents: [
    MatchIncident(type: 10, position: 1, time: 0),
    MatchIncident(type: 1, position: 1, time: 15, playerName: '球员甲', homeScore: 1, awayScore: 0),
    MatchIncident(type: 3, position: 0, time: 28, playerName: '球员乙'),
    MatchIncident(type: 2, position: 1, time: 38),
    MatchIncident(type: 11, position: 1, time: 45),
    MatchIncident(type: 1, position: 0, time: 52, playerName: '球员丙', homeScore: 1, awayScore: 1),
    MatchIncident(type: 9, position: 1, time: 63, inPlayerName: '球员丁', outPlayerName: '球员甲'),
    MatchIncident(type: 3, position: 1, time: 74, playerName: '球员戊'),
    MatchIncident(type: 1, position: 1, time: 82, playerName: '球员丁', homeScore: 2, awayScore: 1),
    MatchIncident(type: 1, position: 1, time: 89, playerName: '球员己', homeScore: 3, awayScore: 1),
    MatchIncident(type: 12, position: 1, time: 90),
  ],
  stats: [
    MatchStat(label: '角球', home: 5, away: 3),
    MatchStat(label: '黄牌', home: 1, away: 2),
    MatchStat(label: '红牌', home: 0, away: 0),
    MatchStat(label: '点球', home: 0, away: 0),
    MatchStat(label: '射正', home: 6, away: 4),
    MatchStat(label: '射偏', home: 4, away: 5),
    MatchStat(label: '进攻', home: 58, away: 47),
    MatchStat(label: '危险进攻', home: 22, away: 15),
    MatchStat(label: '控球率', home: 54, away: 46),
  ],
);

// ─── Lineups ──────────────────────────────────────────────────────────────────

LineupPlayer _player(String id, String name, int shirt, String pos, {int first = 1}) =>
    LineupPlayer(
      id: id,
      name: name,
      cnName: name,
      logo: '',
      shirtNumber: shirt,
      position: pos,
      x: null,
      y: null,
      rating: '',
      first: first,
      captain: 0,
    );

final mockLineups = FootballLineups(
  home: [
    _player('h1', '球员甲一', 1, 'GK'),
    _player('h2', '球员甲二', 2, 'DF'),
    _player('h3', '球员甲三', 5, 'DF'),
    _player('h4', '球员甲四', 6, 'DF'),
    _player('h5', '球员甲五', 3, 'DF'),
    _player('h6', '球员甲六', 8, 'MF'),
    _player('h7', '球员甲七', 4, 'MF'),
    _player('h8', '球员甲八', 10, 'MF'),
    _player('h9', '球员甲九', 7, 'FW'),
    _player('h10', '球员甲十', 9, 'FW'),
    _player('h11', '球员甲十一', 11, 'FW'),
    _player('h12', '球员甲十二', 12, 'GK', first: 0),
    _player('h13', '球员甲十三', 14, 'DF', first: 0),
    _player('h14', '球员甲十四', 16, 'MF', first: 0),
    _player('h15', '球员甲十五', 17, 'FW', first: 0),
  ],
  away: [
    _player('a1', '球员乙一', 1, 'GK'),
    _player('a2', '球员乙二', 2, 'DF'),
    _player('a3', '球员乙三', 4, 'DF'),
    _player('a4', '球员乙四', 5, 'DF'),
    _player('a5', '球员乙五', 3, 'DF'),
    _player('a6', '球员乙六', 6, 'MF'),
    _player('a7', '球员乙七', 8, 'MF'),
    _player('a8', '球员乙八', 10, 'MF'),
    _player('a9', '球员乙九', 7, 'FW'),
    _player('a10', '球员乙十', 9, 'FW'),
    _player('a11', '球员乙十一', 11, 'FW'),
    _player('a12', '球员乙十二', 13, 'GK', first: 0),
    _player('a13', '球员乙十三', 15, 'DF', first: 0),
    _player('a14', '球员乙十四', 18, 'MF', first: 0),
    _player('a15', '球员乙十五', 19, 'FW', first: 0),
  ],
);
