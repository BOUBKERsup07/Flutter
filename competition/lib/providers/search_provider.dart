import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competition.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import '../providers/favorites_provider.dart';
import '../main.dart';

enum SearchType { competition, team, player }

class SearchProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Competition> _competitions = [];
  List<Team> _teams = [];
  List<Player> _players = [];
  
  bool _isLoading = false;
  String _searchQuery = '';
  SearchType _currentSearchType = SearchType.competition;
  String _errorMessage = '';
  
  // Getters
  List<Competition> get competitions => _competitions;
  List<Team> get teams => _teams;
  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  SearchType get currentSearchType => _currentSearchType;
  String get errorMessage => _errorMessage;
  
  // Set search type
  void setSearchType(SearchType type) {
    if (_currentSearchType != type) {
      _currentSearchType = type;
      // Clear previous results when changing type
      _clearResults();
      
      // Si une recherche est en cours, effectuer la recherche avec le nouveau type
      if (_searchQuery.isNotEmpty) {
        search(_searchQuery);
      } else {
        // Sinon, charger les données initiales pour le nouveau type
        loadInitialData();
      }
      
      notifyListeners();
    }
  }
  
  // Clear search results
  void _clearResults() {
    _competitions = [];
    _teams = [];
    _players = [];
    _errorMessage = '';
  }
  
  // Perform search based on current search type
  Future<void> search(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      switch (_currentSearchType) {
        case SearchType.competition:
          _competitions = await _apiService.searchCompetitions(query);
          break;
        case SearchType.team:
          _teams = await _apiService.searchTeams(query);
          break;
        case SearchType.player:
          _players = await _apiService.searchPlayers(query);
          break;
      }
    } catch (e) {
      _errorMessage = 'Error searching: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load initial data
  Future<void> loadInitialData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      switch (_currentSearchType) {
        case SearchType.competition:
          _competitions = await _apiService.getCompetitions();
          break;
        case SearchType.team:
          // Get teams from Premier League as default
          _teams = await _apiService.getTeamsByCompetition(2021);
          break;
        case SearchType.player:
          // Get Manchester United players as default
          _players = await _apiService.getPlayersByTeam(66);
          break;
      }
    } catch (e) {
      _errorMessage = 'Error loading data: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get details for a specific item
  Future<Competition> getCompetitionDetails(int id) async {
    return await _apiService.getCompetition(id);
  }
  
  // Get team details - used by TeamDetailsScreen
  Future<Team> getTeamDetails(int id) async {
    return await _apiService.getTeam(id);
  }
  
  // Alias for getTeamDetails to fix the error in team_details_screen.dart
  Future<Team> getTeam(int id) async {
    return await getTeamDetails(id);
  }
  
  // Méthode pour obtenir toutes les équipes pour la carte, y compris les favoris
  Future<List<Team>> getAllTeamsForMap() async {
    try {
      // Obtenir les équipes françaises de base
      final List<Team> teamsWithLocations = await _apiService.getTeamsWithLocations();
      
      // Vérifier si le contexte est disponible
      if (navigatorKey.currentContext != null) {
        // Obtenir les équipes favorites
        final favoritesProvider = Provider.of<FavoritesProvider>(navigatorKey.currentContext!, listen: false);
        final List<Team> favoriteTeams = favoritesProvider.favoriteTeams;
        
        // Ajouter les équipes favorites qui ne sont pas déjà dans la liste
        for (final favoriteTeam in favoriteTeams) {
          // Vérifier si l'équipe favorite a des coordonnées
          if (favoriteTeam.latitude != null && favoriteTeam.longitude != null) {
            // Vérifier si l'équipe n'est pas déjà dans la liste
            if (!teamsWithLocations.any((team) => team.id == favoriteTeam.id)) {
              teamsWithLocations.add(favoriteTeam);
            }
          }
        }
      }
      
      return teamsWithLocations;
    } catch (e) {
      _errorMessage = 'Error loading teams: ${e.toString()}';
      debugPrint(_errorMessage);
      return [];
    }
  }
  
  // Get players for a team
  Future<List<Player>> getTeamPlayers(int teamId) async {
    return await _apiService.getPlayersByTeam(teamId);
  }
  
  // Get teams for a competition - used by CompetitionDetailsScreen
  Future<List<Team>> getTeamsByCompetition(int competitionId) async {
    return await _apiService.getTeamsByCompetition(competitionId);
  }
  
  // Get teams with location data for the map
  Future<List<Team>> getTeamsWithLocations() async {
    return await _apiService.getTeamsWithLocations();
  }
}
