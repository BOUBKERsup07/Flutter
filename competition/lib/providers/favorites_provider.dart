import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../data/database_helper.dart';

class FavoritesProvider with ChangeNotifier {
  List<Team> _favoriteTeams = [];
  List<Player> _favoritePlayers = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _isLoading = false;

  List<Team> get favoriteTeams => _favoriteTeams;
  List<Player> get favoritePlayers => _favoritePlayers;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    _loadFavorites();
  }
  
  // Ajouter les équipes françaises aux favoris
  Future<void> addFrenchTeamsToFavorites(List<Team> teams) async {
    for (final team in teams) {
      if (!_favoriteTeams.any((t) => t.id == team.id)) {
        await addFavoriteTeam(team);
      }
    }
  }

  Future<void> _loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger les équipes favorites depuis la base de données
      List<Team> teams = await _databaseHelper.getFavoriteTeams();
      
      // S'assurer que toutes les équipes ont des coordonnées valides en utilisant le géocodage
      List<Team> teamsWithCoordinates = [];
      for (var team in teams) {
        // Utiliser la méthode asynchrone pour obtenir des coordonnées précises
        Team teamWithCoordinates = await team.withValidCoordinatesAsync();
        teamsWithCoordinates.add(teamWithCoordinates);
      }
      _favoriteTeams = teamsWithCoordinates;
      
      // Charger les joueurs favoris
      _favoritePlayers = await _databaseHelper.getFavoritePlayers();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Team operations
  Future<void> addFavoriteTeam(Team team) async {
    try {
      // S'assurer que l'équipe a des coordonnées valides pour la carte
      // Utiliser la méthode asynchrone pour obtenir des coordonnées précises via géocodage
      final teamWithCoordinates = await team.withValidCoordinatesAsync();
      
      // Insérer l'équipe avec coordonnées dans la base de données
      await _databaseHelper.insertFavoriteTeam(teamWithCoordinates);
      
      // Ajouter à la liste en mémoire
      _favoriteTeams.add(teamWithCoordinates);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding favorite team: $e');
    }
  }

  Future<void> removeFavoriteTeam(int teamId) async {
    try {
      await _databaseHelper.deleteFavoriteTeam(teamId);
      _favoriteTeams.removeWhere((team) => team.id == teamId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite team: $e');
    }
  }

  Future<bool> isTeamFavorite(int teamId) async {
    return await _databaseHelper.isTeamFavorite(teamId);
  }

  // Player operations
  Future<void> addFavoritePlayer(Player player) async {
    try {
      await _databaseHelper.insertFavoritePlayer(player);
      _favoritePlayers.add(player);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding favorite player: $e');
    }
  }

  Future<void> removeFavoritePlayer(int playerId) async {
    try {
      await _databaseHelper.deleteFavoritePlayer(playerId);
      _favoritePlayers.removeWhere((player) => player.id == playerId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite player: $e');
    }
  }

  Future<bool> isPlayerFavorite(int playerId) async {
    return await _databaseHelper.isPlayerFavorite(playerId);
  }

  // Refresh favorites from database
  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }
}
