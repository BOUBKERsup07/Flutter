import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/search_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/competition_item.dart';
import '../widgets/team_item.dart';
import '../widgets/player_item.dart';
import '../widgets/search_filter.dart';
import '../widgets/custom_shimmer.dart';
import 'details/competition_details_screen.dart';
import 'details/team_details_screen.dart';
import 'details/player_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showRecentSearches = false;
  List<String> _recentSearches = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FocusNode _searchFocusNode = FocusNode();
  
  // Nombre maximum de recherches récentes à conserver
  static const int _maxRecentSearches = 5;
  
  // Clé pour stocker les recherches récentes
  static const String _recentSearchesKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    
    // Initialiser l'animation pour les transitions fluides
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Charger les recherches récentes depuis les préférences
    _loadRecentSearches();
    
    // Charger les données initiales lorsque l'écran est créé
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).loadInitialData();
    });
    
    // Ajouter un écouteur pour mettre à jour la recherche automatiquement lorsque le texte change
    _searchController.addListener(() {
      // Attendre un court instant avant de lancer la recherche pour éviter trop d'appels
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_searchController.text == _searchController.text.trim()) {
          _performSearch();
        }
      });
    });
    
    // Écouter les changements de focus pour afficher/masquer les recherches récentes
    _searchFocusNode.addListener(_onFocusChange);
  }
  
  // Charger les recherches récentes
  Future<void> _loadRecentSearches() async {
    // Ici, vous pourriez utiliser SharedPreferences pour charger les recherches récentes
    // Pour l'instant, nous utilisons une liste statique pour la démonstration
    _recentSearches = [
      'Real Madrid',
      'Barcelona',
      'Premier League',
      'Ligue 1',
      'Champions League'
    ];
  }
  
  // Sauvegarder une nouvelle recherche dans l'historique
  void _saveSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      // Supprimer la requête si elle existe déjà (pour la déplacer en haut)
      _recentSearches.remove(query);
      
      // Ajouter la nouvelle requête au début de la liste
      _recentSearches.insert(0, query);
      
      // Limiter le nombre de recherches récentes
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }
    });
    
    // Ici, vous pourriez sauvegarder la liste mise à jour dans SharedPreferences
  }
  
  // Gérer les changements de focus dans le champ de recherche
  void _onFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showRecentSearches = true;
      });
      _animationController.forward();
    } else if (!_searchFocusNode.hasFocus) {
      setState(() {
        _showRecentSearches = false;
      });
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    
    if (query.isNotEmpty) {
      // Si la requête n'est pas vide, effectuer la recherche
      searchProvider.search(query);
      
      // Sauvegarder la recherche dans l'historique
      _saveSearch(query);
      
      // Masquer les recherches récentes
      setState(() {
        _showRecentSearches = false;
      });
    } else {
      // Si la requête est vide, recharger les données initiales
      searchProvider.loadInitialData();
      
      // Afficher les recherches récentes si le champ a le focus
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showRecentSearches = true;
        });
      }
    }
  }

  // Méthode pour construire la liste des recherches récentes
  Widget _buildRecentSearchesList() {
    return AnimatedOpacity(
      opacity: _showRecentSearches ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: _showRecentSearches
          ? Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recherches récentes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (_recentSearches.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _recentSearches.clear();
                              });
                            },
                            child: const Text('Effacer tout'),
                          ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  if (_recentSearches.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucune recherche récente'),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentSearches.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(_recentSearches[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _recentSearches.removeAt(index);
                              });
                            },
                          ),
                          onTap: () {
                            _searchController.text = _recentSearches[index];
                            _performSearch();
                          },
                        );
                      },
                    ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // Méthode pour construire le champ de recherche amélioré
  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  // Méthode pour construire l'indicateur de chargement
  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ShimmerList(
          isTeamList: Provider.of<SearchProvider>(context, listen: false).currentSearchType == SearchType.team,
        ),
      ],
    );
  }

  // Méthode pour construire le message d'erreur
  Widget _buildErrorMessage(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Provider.of<SearchProvider>(context, listen: false).loadInitialData();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire le message "Aucun résultat trouvé"
  Widget _buildEmptyResults(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty) ...[  
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _performSearch();
              },
              child: const Text('Effacer la recherche'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche Sportive'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Champ de recherche amélioré
          _buildSearchField(),
          
          // Filtres de recherche
          const SearchFilter(),
          
          // Liste des recherches récentes (visible uniquement lorsque le champ a le focus)
          _buildRecentSearchesList(),
          
          // Résultats
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return _buildLoadingIndicator();
                }
                
                if (searchProvider.errorMessage.isNotEmpty) {
                  return _buildErrorMessage(searchProvider.errorMessage);
                }
                
                // Afficher la liste appropriée en fonction du type de recherche
                switch (searchProvider.currentSearchType) {
                  case SearchType.competition:
                    final competitions = searchProvider.competitions;
                    if (competitions.isEmpty) {
                      return _buildEmptyResults('Aucune compétition trouvée');
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: competitions.length,
                      itemBuilder: (context, index) {
                        return CompetitionItem(
                          competition: competitions[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompetitionDetailsScreen(
                                  competitionId: competitions[index].id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                    
                  case SearchType.team:
                    final teams = searchProvider.teams;
                    if (teams.isEmpty) {
                      return _buildEmptyResults('Aucune équipe trouvée');
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        return TeamItem(
                          team: teams[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamDetailsScreen(
                                  teamId: teams[index].id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                    
                  case SearchType.player:
                    final players = searchProvider.players;
                    if (players.isEmpty) {
                      return _buildEmptyResults('Aucun joueur trouvé');
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        return PlayerItem(
                          player: players[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerDetailsScreen(
                                  playerId: players[index].id,
                                  player: players[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
