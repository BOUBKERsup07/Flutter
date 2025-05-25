import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../utils/app_theme.dart';
import '../screens/details/team_details_screen.dart';
import '../providers/favorites_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SimpleTeamDialog extends StatelessWidget {
  final Team team;
  
  const SimpleTeamDialog({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre et logo
                    Row(
                      children: [
                        if (team.crest != null && team.crest!.isNotEmpty)
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryColor, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                team.crest!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppTheme.primaryColor,
                                  child: Center(child: Text(team.tla, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(team.tla, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                          ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              if (team.venue != null && team.venue!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Stade: ${team.venue}',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    
                    // Informations
                    if (team.founded != null)
                      _buildInfoRow('Année de fondation', '${team.founded}', Icons.calendar_today),
                    if (team.clubColors != null && team.clubColors!.isNotEmpty)
                      _buildInfoRow('Couleurs', team.clubColors!, Icons.color_lens),
                    if (team.address != null && team.address!.isNotEmpty)
                      _buildInfoRow('Adresse', team.address!, Icons.location_on),
                    
                    const SizedBox(height: 20),
                    
                    // Bouton pour ajouter/supprimer des favoris
                    Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, child) {
                        final bool isFavorite = favoritesProvider.favoriteTeams.any((favTeam) => favTeam.id == team.id);
                        
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isFavorite) {
                                favoritesProvider.removeFavoriteTeam(team.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${team.name} retiré des favoris')),
                                );
                              } else {
                                favoritesProvider.addFavoriteTeam(team);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${team.name} ajouté aux favoris')),
                                );
                              }
                            },
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, size: 18),
                            label: Text(
                              isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris', 
                              style: const TextStyle(fontSize: 14)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFavorite ? Colors.red : Colors.grey.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    // Bouton détails
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamDetailsScreen(
                                teamId: team.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sports_soccer, size: 18),
                        label: const Text('Détails', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Bouton Google Maps
                    if (team.latitude != null && team.longitude != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openGoogleMaps(context, team.latitude!, team.longitude!, team.name),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Google Maps', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Ligne d'information simplifiée
  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour ouvrir Google Maps
  Future<void> _openGoogleMaps(BuildContext context, double latitude, double longitude, String label) async {
    // Construire l'URL avec le nom de l'équipe et l'adresse si disponible
    String query;
    if (team.address != null && team.address!.isNotEmpty) {
      // Utiliser le nom de l'équipe et l'adresse pour une recherche plus précise
      query = Uri.encodeComponent('${team.name}, ${team.address}');
    } else {
      // Utiliser les coordonnées si l'adresse n'est pas disponible
      query = '$latitude,$longitude';
    }
    
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
}
