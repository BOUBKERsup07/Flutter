import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/competition.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../utils/network_utils.dart';
import '../utils/constants.dart';

class ApiService {
  // Base URL from constants
  static const String baseUrl = Constants.apiBaseUrl;
  
  // API key for Football-Data.org
  static const String apiKey = '2e41e44e31754e48b9b91087ee7a5f67';
  
  // HTTP headers for API requests
  static final Map<String, String> headers = {
    'X-Auth-Token': apiKey,
    'Content-Type': 'application/json',
  };
  
  // Timeout duration for API requests
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Get all available competitions
  Future<List<Competition>> getCompetitions() async {
    // Check for internet connection
    if (!await NetworkUtils.hasInternetConnection()) {
      throw Exception('No internet connection. Please check your network.');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final competitions = data['competitions'] as List;
        return competitions.map((json) => Competition.fromJson(json)).toList();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        // Si l'accès est refusé, retourner des données de secours
        return _getFallbackCompetitions();
      } else {
        throw Exception(NetworkUtils.handleApiError(response));
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // En cas d'erreur, retourner des données de secours
      return _getFallbackCompetitions();
    }
  }
  
  // Données de secours pour les compétitions
  List<Competition> _getFallbackCompetitions() {
    return [
      Competition(
        id: 2015,
        name: 'Ligue 1',
        code: 'FL1',
        type: 'LEAGUE',
        emblem: 'https://crests.football-data.org/FL1.png',
        currentSeason: '2023-08-01 - 2024-05-31',
        numberOfAvailableSeasons: 5,
        area: 'France',
      ),
      Competition(
        id: 2021,
        name: 'Premier League',
        code: 'PL',
        type: 'LEAGUE',
        emblem: 'https://crests.football-data.org/PL.png',
        currentSeason: '2023-08-01 - 2024-05-31',
        numberOfAvailableSeasons: 5,
        area: 'England',
      ),
      Competition(
        id: 2014,
        name: 'La Liga',
        code: 'PD',
        type: 'LEAGUE',
        emblem: 'https://crests.football-data.org/PD.png',
        currentSeason: '2023-08-01 - 2024-05-31',
        numberOfAvailableSeasons: 5,
        area: 'Spain',
      ),
      Competition(
        id: 2019,
        name: 'Serie A',
        code: 'SA',
        type: 'LEAGUE',
        emblem: 'https://crests.football-data.org/SA.png',
        currentSeason: '2023-08-01 - 2024-05-31',
        numberOfAvailableSeasons: 5,
        area: 'Italy',
      ),
      Competition(
        id: 2002,
        name: 'Bundesliga',
        code: 'BL1',
        type: 'LEAGUE',
        emblem: 'https://crests.football-data.org/BL1.png',
        currentSeason: '2023-08-01 - 2024-05-31',
        numberOfAvailableSeasons: 5,
        area: 'Germany',
      ),
    ];
  }

  // Search competitions by name
  Future<List<Competition>> searchCompetitions(String query) async {
    try {
      // Utiliser directement nos données de secours
      final allCompetitions = _getFallbackCompetitions();
      if (query.isEmpty) return allCompetitions;
      
      // Filtrer les compétitions par nom
      return allCompetitions.where((competition) => 
        competition.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      // En cas d'erreur, retourner une liste vide plutôt qu'une erreur
      return [];
    }
  }

  // Get details for a specific competition
  Future<Competition> getCompetition(int id) async {
    // Check for internet connection
    if (!await NetworkUtils.hasInternetConnection()) {
      throw Exception('No internet connection. Please check your network.');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$id'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Competition.fromJson(json.decode(response.body));
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        // Si l'accès est refusé, retourner des données de secours
        return _getFallbackCompetition(id);
      } else {
        throw Exception(NetworkUtils.handleApiError(response));
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // En cas d'erreur, retourner des données de secours
      return _getFallbackCompetition(id);
    }
  }
  
  // Récupérer une compétition spécifique depuis les données de secours
  Competition _getFallbackCompetition(int id) {
    // Trouver la compétition avec l'ID correspondant
    for (final competition in _getFallbackCompetitions()) {
      if (competition.id == id) {
        return competition;
      }
    }
    
    // Si aucune compétition n'est trouvée, retourner Ligue 1 par défaut
    return _getFallbackCompetitions().first;
  }

  // Get teams for a specific competition
  Future<List<Team>> getTeamsByCompetition(int competitionId) async {
    // Check for internet connection
    if (!await NetworkUtils.hasInternetConnection()) {
      throw Exception('No internet connection. Please check your network.');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/competitions/$competitionId/teams'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final teams = data['teams'] as List;
        return teams.map((json) => Team.fromJson(json)).toList();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        // Si l'accès est refusé, retourner des données de secours
        return _getFallbackTeams();
      } else {
        throw Exception(NetworkUtils.handleApiError(response));
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // En cas d'erreur, retourner des données de secours
      return _getFallbackTeams();
    }
  }
  
  // Données de secours pour les équipes
  List<Team> _getFallbackTeams() {
    return [
      Team(
        id: 1,
        name: 'Paris Saint-Germain',
        tla: 'PSG',
        crest: 'https://crests.football-data.org/524.png',
        venue: 'Parc des Princes',
        founded: 1970,
        clubColors: 'Blue, Red',
        address: 'Paris, France',
        latitude: 48.8414,
        longitude: 2.2530,
      ),
      Team(
        id: 2,
        name: 'Olympique de Marseille',
        tla: 'OM',
        crest: 'https://crests.football-data.org/516.png',
        venue: 'Stade Vélodrome',
        founded: 1899,
        clubColors: 'Blue, White',
        address: 'Marseille, France',
        latitude: 43.2696,
        longitude: 5.3950,
      ),
      Team(
        id: 3,
        name: 'Olympique Lyonnais',
        tla: 'OL',
        crest: 'https://crests.football-data.org/523.png',
        venue: 'Groupama Stadium',
        founded: 1950,
        clubColors: 'Red, Blue',
        address: 'Lyon, France',
        latitude: 45.7653,
        longitude: 4.9822,
      ),
      Team(
        id: 4,
        name: 'AS Monaco',
        tla: 'ASM',
        crest: 'https://crests.football-data.org/548.png',
        venue: 'Stade Louis II',
        founded: 1924,
        clubColors: 'Red, White',
        address: 'Monaco',
        latitude: 43.7272,
        longitude: 7.4154,
      ),
      Team(
        id: 5,
        name: 'LOSC Lille',
        tla: 'LIL',
        crest: 'https://crests.football-data.org/521.png',
        venue: 'Stade Pierre-Mauroy',
        founded: 1944,
        clubColors: 'Red, Blue',
        address: 'Lille, France',
        latitude: 50.6119,
        longitude: 3.1301,
      ),
    ];
  }

  // Search teams by name
  Future<List<Team>> searchTeams(String query) async {
    try {
      // Utiliser directement nos données de secours
      final allTeams = _getFallbackTeams();
      
      if (query.isEmpty) {
        return allTeams;
      }
      
      // Filtrer les équipes par nom
      return allTeams.where((team) => 
        team.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      // En cas d'erreur, retourner une liste vide plutôt qu'une erreur
      return [];
    }
  }

  // Get a specific team by ID
  Future<Team> getTeam(int id) async {
    // Check for internet connection
    if (!await NetworkUtils.hasInternetConnection()) {
      throw Exception('No internet connection. Please check your network.');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams/$id'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Team.fromJson(json.decode(response.body));
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        // Si l'accès est refusé, retourner des données de secours
        return _getFallbackTeam(id);
      } else {
        throw Exception(NetworkUtils.handleApiError(response));
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // En cas d'erreur, retourner des données de secours
      return _getFallbackTeam(id);
    }
  }
  
  // Récupérer une équipe spécifique depuis les données de secours
  Team _getFallbackTeam(int id) {
    // Récupérer toutes les équipes de secours
    final teams = _getFallbackTeams();
    
    // Vérifier si l'ID est valide pour nos équipes de secours
    if (id >= 1 && id <= 5) {
      // Rechercher l'équipe avec l'ID exact
      final exactMatch = teams.where((team) => team.id == id).toList();
      if (exactMatch.isNotEmpty) {
        return exactMatch.first;
      }
    }
    
    // Si l'ID ne correspond à aucune équipe de secours ou est invalide, utiliser PSG par défaut
    return teams.first; // Paris Saint-Germain (id: 1)
  }

  // Get players for a specific team
  Future<List<Player>> getPlayersByTeam(int teamId) async {
    // Check for internet connection
    if (!await NetworkUtils.hasInternetConnection()) {
      throw Exception('No internet connection. Please check your network.');
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final teamName = data['name'];
        final squad = data['squad'] as List? ?? [];
        return squad.map((json) => Player.fromJson(json, teamId: teamId, teamName: teamName)).toList();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        // Si l'accès est refusé, retourner des données de secours
        return _getFallbackPlayers(teamId);
      } else {
        throw Exception(NetworkUtils.handleApiError(response));
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // En cas d'erreur, retourner des données de secours
      return _getFallbackPlayers(teamId);
    }
  }
  
  // Données de secours pour les joueurs
  List<Player> _getFallbackPlayers(int teamId) {
    // Récupérer le nom de l'équipe à partir de l'ID
    String teamName = 'Équipe';
    for (final team in _getFallbackTeams()) {
      if (team.id == teamId) {
        teamName = team.name;
        break;
      }
    }
    
    // Si l'ID n'est pas dans nos équipes de secours, utiliser PSG par défaut
    if (teamId > 5 || teamId < 1) {
      teamId = 1;
      teamName = 'Paris Saint-Germain';
    }
    
    // Joueurs pour PSG
    if (teamId == 1) {
      return [
        Player(
          id: 101,
          name: 'Kylian Mbappé',
          position: 'Attaquant',
          dateOfBirth: '1998-12-20',
          nationality: 'France',
          shirtNumber: 7,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/342229-1602849394.jpg',
        ),
        Player(
          id: 102,
          name: 'Marquinhos',
          position: 'Défenseur',
          dateOfBirth: '1994-05-14',
          nationality: 'Brésil',
          shirtNumber: 5,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/181767-1602849493.jpg',
        ),
        Player(
          id: 103,
          name: 'Gianluigi Donnarumma',
          position: 'Gardien',
          dateOfBirth: '1999-02-25',
          nationality: 'Italie',
          shirtNumber: 1,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/315858-1595944054.jpg',
        ),
      ];
    }
    // Joueurs pour OM
    else if (teamId == 2) {
      return [
        Player(
          id: 201,
          name: 'Pierre-Emerick Aubameyang',
          position: 'Attaquant',
          dateOfBirth: '1989-06-18',
          nationality: 'Gabon',
          shirtNumber: 10,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/58864-1666344712.jpg',
        ),
        Player(
          id: 202,
          name: 'Chancel Mbemba',
          position: 'Défenseur',
          dateOfBirth: '1994-08-08',
          nationality: 'RD Congo',
          shirtNumber: 5,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/171305-1666344823.jpg',
        ),
        Player(
          id: 203,
          name: 'Jonathan Clauss',
          position: 'Défenseur',
          dateOfBirth: '1992-09-25',
          nationality: 'France',
          shirtNumber: 7,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/364248-1666344871.jpg',
        ),
      ];
    }
    // Joueurs pour Lyon (OL)
    else if (teamId == 3) {
      return [
        Player(
          id: 301,
          name: 'Alexandre Lacazette',
          position: 'Attaquant',
          dateOfBirth: '1991-05-28',
          nationality: 'France',
          shirtNumber: 10,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/93720-1657712640.jpg',
        ),
        Player(
          id: 302,
          name: 'Rayan Cherki',
          position: 'Milieu',
          dateOfBirth: '2003-08-17',
          nationality: 'France',
          shirtNumber: 18,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/538312-1657712747.jpg',
        ),
        Player(
          id: 303,
          name: 'Anthony Lopes',
          position: 'Gardien',
          dateOfBirth: '1990-10-01',
          nationality: 'Portugal',
          shirtNumber: 1,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/73099-1657712792.jpg',
        ),
      ];
    }
    // Joueurs pour Monaco (ASM)
    else if (teamId == 4) {
      return [
        Player(
          id: 401,
          name: 'Wissam Ben Yedder',
          position: 'Attaquant',
          dateOfBirth: '1990-08-12',
          nationality: 'France',
          shirtNumber: 10,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/146362-1663876753.jpg',
        ),
        Player(
          id: 402,
          name: 'Takumi Minamino',
          position: 'Milieu',
          dateOfBirth: '1995-01-16',
          nationality: 'Japon',
          shirtNumber: 18,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/165793-1663876822.jpg',
        ),
      ];
    }
    // Joueurs pour Lille (LOSC)
    else if (teamId == 5) {
      return [
        Player(
          id: 501,
          name: 'Jonathan David',
          position: 'Attaquant',
          dateOfBirth: '2000-01-14',
          nationality: 'Canada',
          shirtNumber: 9,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/486659-1662731183.jpg',
        ),
        Player(
          id: 502,
          name: 'Lucas Chevalier',
          position: 'Gardien',
          dateOfBirth: '2001-10-25',
          nationality: 'France',
          shirtNumber: 30,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/649551-1662731240.jpg',
        ),
      ];
    }
    // Joueurs par défaut pour les autres équipes
    else {
      return [
        Player(
          id: teamId * 100 + 1,
          name: 'Joueur 1',
          position: 'Attaquant',
          dateOfBirth: '1995-01-01',
          nationality: 'France',
          shirtNumber: 10,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/default.jpg',
        ),
        Player(
          id: teamId * 100 + 2,
          name: 'Joueur 2',
          position: 'Milieu',
          dateOfBirth: '1996-02-02',
          nationality: 'France',
          shirtNumber: 8,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/default.jpg',
        ),
        Player(
          id: teamId * 100 + 3,
          name: 'Joueur 3',
          position: 'Défenseur',
          dateOfBirth: '1997-03-03',
          nationality: 'France',
          shirtNumber: 4,
          teamId: teamId,
          teamName: teamName,
          imageUrl: 'https://img.a.transfermarkt.technology/portrait/big/default.jpg',
        ),
      ];
    }
  }

  // Search players by name
  Future<List<Player>> searchPlayers(String query) async {
    try {
      // Utiliser les données de secours du PSG (ID: 1) au lieu de Manchester United
      final int teamId = 1; // Paris Saint-Germain
      
      if (query.isEmpty) {
        return _getFallbackPlayers(teamId);
      }
      
      // Obtenir tous les joueurs de toutes les équipes de secours
      final List<Player> allPlayers = [];
      for (int i = 1; i <= 5; i++) {
        allPlayers.addAll(_getFallbackPlayers(i));
      }
      
      // Filtrer les joueurs par nom
      return allPlayers.where((player) => 
        player.name.toLowerCase().contains(query.toLowerCase())).toList();
    } catch (e) {
      // En cas d'erreur, retourner quelques joueurs par défaut
      return _getFallbackPlayers(1).take(3).toList();
    }
  }
  
  // Méthode publique pour obtenir les équipes françaises pour les favoris
  List<Team> getFrenchTeams() {
    return _getFallbackTeams();
  }

  // Get teams with location data for map display
  Future<List<Team>> getTeamsWithLocations() async {
    try {
      // Utiliser directement nos données de secours qui ont déjà des coordonnées
      return _getFallbackTeams();
    } catch (e) {
      // En cas d'erreur, retourner une liste vide plutôt qu'une erreur
      return [];
    }
  }
}
