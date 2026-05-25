enum LeagueSport {
  football,
  basketball;

  String get apiPath => switch (this) {
    LeagueSport.football => 'football',
    LeagueSport.basketball => 'basketball',
  };

  static LeagueSport fromString(String value) => switch (value) {
    'basketball' => LeagueSport.basketball,
    _ => LeagueSport.football,
  };
}
