import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/team.dart';
import '../../models/player.dart';
import '../../widgets/player_item.dart';
import 'player_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamDetailsScreen extends StatefulWidget {
  final int teamId;

  const TeamDetailsScreen({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Team? _team;
  List<Player> _players = [];
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadTeamDetails();
  }

  Future<void> _loadTeamDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      
      // Load team details
      _team = await searchProvider.getTeam(widget.teamId);
      
      // Load players for this team
      _players = await searchProvider.getTeamPlayers(widget.teamId);
      
      // Check if team is in favorites
      _isFavorite = await favoritesProvider.isTeamFavorite(widget.teamId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load team details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_team == null) return;
    
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    if (_isFavorite) {
      await favoritesProvider.addFavoriteTeam(_team!);
    } else {
      await favoritesProvider.removeFavoriteTeam(_team!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_team?.name ?? 'Team Details'),
        actions: [
          if (_team != null)
            IconButton(
              icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildTeamDetails(),
    );
  }

  Widget _buildTeamDetails() {
    if (_team == null) {
      return const Center(child: Text('No team data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team header
          _buildTeamHeader(),
          
          const Divider(),
          
          // Team info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Short Name', _team!.tla),
                if (_team!.address != null)
                  _buildInfoRow('Address', _team!.address!),
                if (_team!.website != null)
                  _buildInfoRow('Website', _team!.website!),
                if (_team!.founded != null)
                  _buildInfoRow('Founded', _team!.founded.toString()),
                if (_team!.clubColors != null)
                  _buildInfoRow('Club Colors', _team!.clubColors!),
                if (_team!.venue != null)
                  _buildInfoRow('Venue', _team!.venue!),
              ],
            ),
          ),
          
          const Divider(),
          
          // Squad/Players
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Squad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _players.isEmpty
                    ? const Text('No players available')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _players.length,
                        itemBuilder: (context, index) {
                          return PlayerItem(
                            player: _players[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayerDetailsScreen(
                                    playerId: _players[index].id,
                                    player: _players[index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Team crest
          if (_team!.crest != null && _team!.crest!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _team!.crest!,
                height: 120,
                width: 120,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, size: 80),
              ),
            ),
          const SizedBox(height: 16),
          
          // Team name
          Text(
            _team!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
