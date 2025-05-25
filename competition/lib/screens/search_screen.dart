import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../widgets/competition_item.dart';
import '../widgets/team_item.dart';
import '../widgets/player_item.dart';
import '../widgets/search_filter.dart';
import 'details/competition_details_screen.dart';
import 'details/team_details_screen.dart';
import 'details/player_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load initial data when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Provider.of<SearchProvider>(context, listen: false).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _performSearch(),
              )
            : const Text('Sports Search'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search filters
          const SearchFilter(),
          
          // Results
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (searchProvider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      searchProvider.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                // Show appropriate list based on search type
                switch (searchProvider.currentSearchType) {
                  case SearchType.competition:
                    final competitions = searchProvider.competitions;
                    if (competitions.isEmpty) {
                      return const Center(child: Text('No competitions found'));
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
                      return const Center(child: Text('No teams found'));
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
                      return const Center(child: Text('No players found'));
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
      floatingActionButton: FloatingActionButton(
        onPressed: _performSearch,
        child: const Icon(Icons.search),
      ),
    );
  }
}
