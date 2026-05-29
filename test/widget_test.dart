import 'package:flutter_test/flutter_test.dart';
import 'package:sports_app/src/routes/app_routes.dart';

void main() {
  test('league route helpers build expected paths', () {
    expect(
      AppRoutes.leagueDetailPath('football', '123'),
      '/league/detail/football/123',
    );
    expect(
      AppRoutes.leagueTeamPath('basketball', '456'),
      '/league/team/basketball/456',
    );
    expect(
      AppRoutes.leaguePlayerPath('football', '789'),
      '/league/player/football/789',
    );
  });
}
