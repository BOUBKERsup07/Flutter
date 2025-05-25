import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/player.dart';
import 'team_details_screen.dart';

class PlayerDetailsScreen extends StatefulWidget {
  final int playerId;
  final Player player;

  const PlayerDetailsScreen({
    Key? key,
    required this.playerId,
    required this.player,
  }) : super(key: key);

  @override
  State<PlayerDetailsScreen> createState() => _PlayerDetailsScreenState();
}

class _PlayerDetailsScreenState extends State<PlayerDetailsScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFavorite = await favoritesProvider.isPlayerFavorite(widget.playerId);
    
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    if (_isFavorite) {
      await favoritesProvider.addFavoritePlayer(widget.player);
    } else {
      await favoritesProvider.removeFavoritePlayer(widget.player.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player.name),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player header
            _buildPlayerHeader(),
            
            const Divider(),
            
            // Player info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.player.position != null)
                    _buildInfoRow('Position', widget.player.position!),
                  if (widget.player.nationality != null)
                    _buildInfoRow('Nationality', widget.player.nationality!),
                  if (widget.player.dateOfBirth != null)
                    _buildInfoRow('Date of Birth', widget.player.dateOfBirth!),
                  if (widget.player.shirtNumber != null)
                    _buildInfoRow('Shirt Number', widget.player.shirtNumber.toString()),
                  if (widget.player.teamName != null)
                    _buildInfoRow('Team', widget.player.teamName!),
                ],
              ),
            ),
            
            // View team button
            if (widget.player.teamId > 0)
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamDetailsScreen(
                          teamId: widget.player.teamId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.sports_soccer),
                  label: const Text(
                    'Voir l\'\u00e9quipe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Image du joueur ou avatar avec la première lettre du nom
          Hero(
            tag: 'player-${widget.player.id}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                image: widget.player.imageUrl != null && widget.player.imageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.player.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              ),
              child: widget.player.imageUrl == null || widget.player.imageUrl!.isEmpty
                ? Center(
                    child: Text(
                      widget.player.name.isNotEmpty ? widget.player.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            ),
          ),
          const SizedBox(height: 16),
          
          // Player name
          Text(
            widget.player.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Player position
          if (widget.player.position != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.player.position!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icône basée sur le type d'information
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getIconForLabel(label),
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'position':
        return Icons.sports_soccer;
      case 'nationality':
        return Icons.flag;
      case 'date of birth':
        return Icons.cake;
      case 'shirt number':
        return Icons.format_list_numbered;
      case 'team':
        return Icons.group;
      default:
        return Icons.info_outline;
    }
  }
}
