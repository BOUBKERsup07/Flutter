import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/team_item.dart';
import '../widgets/player_item.dart';
import 'details/team_details_screen.dart';
import 'details/player_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Refresh favorites when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).refreshFavorites();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Teams'),
            Tab(text: 'Players'),
          ],
        ),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Teams tab
              _buildTeamsTab(favoritesProvider),
              
              // Players tab
              _buildPlayersTab(favoritesProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamsTab(FavoritesProvider favoritesProvider) {
    final teams = favoritesProvider.favoriteTeams;
    
    if (teams.isEmpty) {
      return const Center(
        child: Text(
          'No favorite teams yet.\nAdd teams to your favorites while browsing!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
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
            ).then((_) {
              // Refresh favorites when returning from details screen
              favoritesProvider.refreshFavorites();
            });
          },
          showFavoriteButton: true,
          isFavorite: true,
        );
      },
    );
  }

  Widget _buildPlayersTab(FavoritesProvider favoritesProvider) {
    final players = favoritesProvider.favoritePlayers;
    
    if (players.isEmpty) {
      return const Center(
        child: Text(
          'No favorite players yet.\nAdd players to your favorites while browsing!',
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
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
            ).then((_) {
              // Refresh favorites when returning from details screen
              favoritesProvider.refreshFavorites();
            });
          },
          showFavoriteButton: true,
          isFavorite: true,
        );
      },
    );
  }
}
