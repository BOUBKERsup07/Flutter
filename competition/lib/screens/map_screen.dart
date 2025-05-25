import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/team.dart';
import '../providers/favorites_provider.dart';
import '../providers/search_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/simple_team_dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Centre sur la France
  static const LatLng _defaultPosition = LatLng(46.603354, 1.888334);
  double _currentZoom = 5.5;

  // Variable pour suivre si le widget est actif
  bool _isActive = false;
  
  @override
  void initState() {
    super.initState();
    _isActive = true;
    _loadTeamLocations();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'assurer que nous n'ajoutons l'écouteur qu'une seule fois
    if (_isActive) {
      // Utiliser didChangeDependencies au lieu de WidgetsBinding.instance.addPostFrameCallback
      // pour éviter les problèmes de cycle de vie
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: true);
      // Au lieu d'utiliser un listener, nous allons réagir aux changements via le provider
      // Cela évite les problèmes de cycle de vie
      if (!favoritesProvider.isLoading && mounted) {
        // Recharger les marqueurs uniquement si nous ne sommes pas déjà en train de charger
        if (!_isLoading) {
          _loadTeamLocations();
        }
      }
    }
  }
  
  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }
  
  // Cette méthode a été supprimée car nous utilisons maintenant didChangeDependencies
  // pour réagir aux changements dans les favoris

  Future<void> _loadTeamLocations() async {
    // Vérifier si le widget est toujours monté
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      // Clear existing markers when reloading
      _markers.clear();
    });

    try {
      // Utiliser la nouvelle méthode qui récupère toutes les équipes, y compris les favoris
      if (!mounted) return;
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      final teams = await searchProvider.getAllTeamsForMap();
      
      // Vérifier à nouveau si le widget est monté après l'opération asynchrone
      if (!mounted) return;
      
      // Add markers for teams with location data
      _addTeamMarkers(teams);
      
      // Centrer la carte sur la France pour voir toutes les équipes
      _moveMap(_defaultPosition);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _moveMap(LatLng position) {
    _mapController.move(position, _currentZoom);
  }
  
  // Ouvrir Google Maps avec les coordonnées de l'équipe
  Future<void> _openGoogleMaps(double latitude, double longitude, String label) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        final bool launched = await launchUrl(
          googleMapsUrl, 
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Maps n\'est pas disponible sur cet appareil')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _addTeamMarkers(List<Team> teams) {
    final markers = <Marker>[];
    // Récupérer les équipes favorites
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final favoriteTeams = favoritesProvider.favoriteTeams;
    
    for (final team in teams) {
      // Only add markers for teams with location data
      if (team.latitude != null && team.longitude != null) {
        final position = LatLng(team.latitude!, team.longitude!);
        // Vérifier si l'équipe est dans les favoris
        final isFavorite = favoriteTeams.any((favTeam) => favTeam.id == team.id);
        
        markers.add(
          Marker(
            point: position,
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () {
                _showTeamInfo(team);
              },
              child: Column(
                children: [
                  // Logo de l'équipe ou icône par défaut
                  if (team.crest != null && team.crest!.isNotEmpty)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFavorite ? Colors.red : AppTheme.primaryColor, 
                          width: isFavorite ? 3 : 2
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
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
                            child: Center(child: Text(team.tla, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isFavorite ? Colors.red : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: isFavorite ? 3 : 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(child: Text(team.tla, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  const SizedBox(height: 4),
                  // Nom de l'équipe en bulle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFavorite ? Colors.red.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isFavorite ? Border.all(color: Colors.red, width: 1) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      team.name,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    
    setState(() {
      _markers.addAll(markers);
    });
  }

  // Méthode corrigée pour afficher les détails de l'équipe sans le texte de débogage vertical
  void _showTeamInfo(Team team) {
    showDialog(
      context: context,
      builder: (context) => SimpleTeamDialog(team: team),
    );
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
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Équipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeamLocations,
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap avec flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultPosition,
              initialZoom: _currentZoom,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _currentZoom = _mapController.camera.zoom;
                }
              },
            ),
            children: [
              // Couche de base de la carte (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Suppression des sous-domaines pour éviter les avertissements
                userAgentPackageName: 'com.example.competition',
                maxZoom: 19,
                minZoom: 3,
                tileProvider: NetworkTileProvider(),
                tileBuilder: (context, child, tile) {
                  return Opacity(
                    opacity: 1.0,
                    child: child,
                  );
                },
                // Utilisation d'un fallback plus fiable
                fallbackUrl: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',
              ),
              
              // Marqueurs pour les équipes
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // Attribution OpenStreetMap (placée correctement dans le Stack)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          
          // Indicateur de chargement
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
            
          // Message d'erreur
          if (_errorMessage.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bouton de zoom +
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () {
              final newZoom = _currentZoom + 1.0;
              if (newZoom <= 19.0) { // Limiter le zoom maximum
                setState(() {
                  _currentZoom = newZoom;
                });
                _mapController.move(_mapController.camera.center, _currentZoom);
              }
            },
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          // Bouton de zoom -
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () {
              final newZoom = _currentZoom - 1.0;
              if (newZoom >= 3.0) { // Limiter le zoom minimum
                setState(() {
                  _currentZoom = newZoom;
                });
                _mapController.move(_mapController.camera.center, _currentZoom);
              }
            },
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 16),
          // Bouton pour recentrer la carte
          FloatingActionButton(
            heroTag: 'center',
            onPressed: () => _moveMap(_defaultPosition),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
