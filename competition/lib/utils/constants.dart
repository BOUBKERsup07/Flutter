class Constants {
  // API related constants
  static const String apiBaseUrl = 'https://api.football-data.org/v4';
  
  // Default IDs for popular competitions and teams
  static const int premierLeagueId = 2021;
  static const int laLigaId = 2014;
  static const int bundesligaId = 2002;
  static const int serieAId = 2019;
  static const int ligue1Id = 2015;
  
  // Default team IDs
  static const int manchesterUnitedId = 66;
  static const int liverpoolId = 64;
  static const int barcelonaId = 81;
  static const int realMadridId = 86;
  static const int bayernMunichId = 5;
  
  // App related constants
  static const String appName = 'Sports Competition';
  static const String appVersion = '1.0.0';
  
  // Database related constants
  static const String databaseName = 'sports_competition.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String favoriteTeamsTable = 'favorite_teams';
  static const String favoritePlayersTable = 'favorite_players';
}
