import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player.dart';
import '../providers/favorites_provider.dart';

class PlayerItem extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;
  final bool showFavoriteButton;
  final bool isFavorite;

  const PlayerItem({
    Key? key,
    required this.player,
    required this.onTap,
    this.showFavoriteButton = false,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image du joueur ou avatar avec la première lettre du nom avec animation Hero
              Hero(
                tag: 'player-${player.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: player.imageUrl != null && player.imageUrl!.isNotEmpty
                    ? NetworkImage(player.imageUrl!)
                    : null,
                  child: player.imageUrl == null || player.imageUrl!.isEmpty
                    ? Text(
                        player.name.isNotEmpty ? player.name[0] : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // Player details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (player.position != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        player.position!,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                    if (player.nationality != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Nationality: ${player.nationality}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                    if (player.teamName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Team: ${player.teamName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Favorite button or arrow icon
              if (showFavoriteButton)
                _buildFavoriteButton(context)
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
      onPressed: () async {
        final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
        
        if (isFavorite) {
          await favoritesProvider.removeFavoritePlayer(player.id);
        } else {
          await favoritesProvider.addFavoritePlayer(player);
        }
      },
    );
  }
}
