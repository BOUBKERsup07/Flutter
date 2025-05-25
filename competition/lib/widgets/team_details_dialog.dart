import 'package:flutter/material.dart';
import '../models/team.dart';
import '../utils/app_theme.dart';
import '../screens/details/team_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamDetailsDialog extends StatelessWidget {
  final Team team;
  
  const TeamDetailsDialog({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (team.crest != null && team.crest!.isNotEmpty)
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
              // Détails de l'équipe en cartes
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (team.founded != null)
                    _buildInfoCard('Année de fondation', '${team.founded}', Icons.calendar_today),
                  if (team.clubColors != null && team.clubColors!.isNotEmpty)
                    _buildInfoCard('Couleurs', team.clubColors!, Icons.color_lens),
                  if (team.address != null && team.address!.isNotEmpty)
                    _buildInfoCard('Adresse', team.address!, Icons.location_on),
                ],
              ),
              const SizedBox(height: 20),
              // Utilisation de Column au lieu de Row pour éviter les problèmes d'overflow
              Column(
                children: [
                  // Bouton pour voir les détails de l'équipe
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
                  // Bouton pour ouvrir Google Maps
                  if (team.latitude != null && team.longitude != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openGoogleMaps(team.latitude!, team.longitude!, team.name);
                        },
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
            ],
          ),
        ),
      ),
    );
  }

  // Méthode pour ouvrir Google Maps
  Future<void> _openGoogleMaps(double latitude, double longitude, String label) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error opening Google Maps: $e');
    }
  }

  // Créer une carte d'information pour les détails de l'équipe
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
