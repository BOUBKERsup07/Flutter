import 'package:geocoding/geocoding.dart';

class Team {
  final int id;
  final String name;
  final String tla;
  final String? crest;
  final String? address;
  final String? website;
  final int? founded;
  final String? clubColors;
  final String? venue;
  final double? latitude;
  final double? longitude;

  Team({
    required this.id,
    required this.name,
    required this.tla,
    this.crest,
    this.address,
    this.website,
    this.founded,
    this.clubColors,
    this.venue,
    this.latitude,
    this.longitude,
  });

  // Créer une Team à partir d'un objet JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      tla: json['tla'] ?? json['shortName'] ?? 'UNK',
      crest: json['crest'] ?? json['crestUrl'],
      address: json['address'],
      website: json['website'],
      founded: json['founded'],
      clubColors: json['clubColors'],
      venue: json['venue'],
      // Ajouter les coordonnées si elles sont disponibles dans le JSON
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
    );
  }

  // Convertir l'objet Team en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tla': tla,
      'crest': crest,
      'address': address,
      'website': website,
      'founded': founded,
      'clubColors': clubColors,
      'venue': venue,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
  
  // Créer une copie de l'équipe avec des coordonnées valides
  Future<Team> withValidCoordinatesAsync() async {
    // Si l'équipe a déjà des coordonnées valides, la retourner telle quelle
    if (latitude != null && longitude != null) {
      return this;
    }
    
    // Coordonnées par défaut (centre de la France)
    double newLat = 46.603354;
    double newLng = 1.888334;
    
    // Essayer d'obtenir les coordonnées à partir de l'adresse si disponible
    if (address != null && address!.isNotEmpty) {
      try {
        // Utiliser le service de géocodage pour obtenir les coordonnées à partir de l'adresse
        List<Location> locations = await locationFromAddress(address!);
        if (locations.isNotEmpty) {
          // Utiliser les coordonnées obtenues du service de géocodage
          return Team(
            id: id,
            name: name,
            tla: tla,
            crest: crest,
            address: address,
            website: website,
            founded: founded,
            clubColors: clubColors,
            venue: venue,
            latitude: locations.first.latitude,
            longitude: locations.first.longitude,
          );
        }
      } catch (e) {
        // En cas d'erreur avec le service de géocodage, continuer avec la méthode de secours
        print('Erreur de géocodage pour $name: $e');
      }
    }
    
    // Si le géocodage a échoué ou n'a pas pu être utilisé, utiliser la méthode de secours
    // Coordonnées des principales équipes européennes
    Map<String, List<double>> teamCoordinates = {
      // France
      'Paris Saint-Germain': [48.8414, 2.2530],
      'Olympique de Marseille': [43.2696, 5.3950],
      'Olympique Lyonnais': [45.7653, 4.9822],
      'AS Monaco': [43.7272, 7.4154],
      'LOSC Lille': [50.6119, 3.1301],
      'Stade Rennais': [48.1073, -1.7107],
      'RC Lens': [50.4322, 2.8142],
      'OGC Nice': [43.7047, 7.1927],
      
      // Angleterre
      'Manchester United': [53.4631, -2.2913],
      'Manchester City': [53.4831, -2.2004],
      'Liverpool': [53.4308, -2.9608],
      'Chelsea': [51.4817, -0.1905],
      'Arsenal': [51.5549, -0.1084],
      'Tottenham': [51.6043, -0.0680],
      
      // Championship (Angleterre)
      'Norwich City FC': [52.6225, 1.3091],
      'Leeds United FC': [53.7772, -1.5724],
      'Sheffield United FC': [53.3703, -1.4705],
      'Middlesbrough FC': [54.5779, -1.2166],
      'Bristol City FC': [51.4400, -2.6206],
      
      // Espagne
      'Real Madrid': [40.4530, -3.6883],
      'Barcelona': [41.3809, 2.1228],
      'FC Barcelona': [41.3809, 2.1228], // Ajout du nom complet pour FC Barcelona
      'Atletico Madrid': [40.4361, -3.5994],
      'Sevilla': [37.3841, -5.9705],
      'Valencia': [39.4748, -0.3585],
      
      // Italie
      'Juventus': [45.1096, 7.6413],
      'Inter': [45.4781, 9.1240],
      'AC Milan': [45.4781, 9.1240],
      'Napoli': [40.8279, 14.1931],
      'Roma': [41.9341, 12.4547],
      
      // Allemagne
      'Bayern Munich': [48.2188, 11.6247],
      'Borussia Dortmund': [51.4926, 7.4518],
      'RB Leipzig': [51.3456, 12.3474],
      'Bayer Leverkusen': [51.0384, 7.0022],
    };
    
    // Vérifier si l'équipe est dans notre liste de coordonnées connues par son nom
    if (teamCoordinates.containsKey(name)) {
      newLat = teamCoordinates[name]![0];
      newLng = teamCoordinates[name]![1];
    } 
    // Vérifier par ID pour les équipes du Championship
    else if (id == 343) { // Norwich City
      newLat = 52.6225;
      newLng = 1.3091;
    } 
    else if (id == 341) { // Leeds United
      newLat = 53.7772;
      newLng = -1.5724;
    } 
    else if (id == 356) { // Sheffield United
      newLat = 53.3703;
      newLng = -1.4705;
    } 
    else if (id == 384) { // Middlesbrough
      newLat = 54.5779;
      newLng = -1.2166;
    } 
    else if (id == 387) { // Bristol City
      newLat = 51.4400;
      newLng = -2.6206;
    }
    // Essayer d'extraire un pays ou une ville de l'adresse
    else if (address != null && address!.isNotEmpty) {
      String addressLower = address!.toLowerCase();
      
      // Coordonnées approximatives des pays
      if (addressLower.contains('france')) {
        newLat = 46.603354; // Centre de la France
        newLng = 1.888334;
      } else if (addressLower.contains('england') || addressLower.contains('royaume-uni') || addressLower.contains('united kingdom')) {
        newLat = 51.5074; // Londres
        newLng = -0.1278;
      } else if (addressLower.contains('spain') || addressLower.contains('espagne')) {
        newLat = 40.4168; // Madrid
        newLng = -3.7038;
      } else if (addressLower.contains('italy') || addressLower.contains('italie')) {
        newLat = 41.9028; // Rome
        newLng = 12.4964;
      } else if (addressLower.contains('germany') || addressLower.contains('allemagne')) {
        newLat = 52.5200; // Berlin
        newLng = 13.4050;
      }
      
      // Ajouter un léger décalage pour éviter que toutes les équipes d'un même pays se superposent
      newLat += (id % 100) * 0.01;
      newLng += (id % 50) * 0.01;
    } else {
      // Si aucune information n'est disponible, utiliser l'ID pour générer des coordonnées
      // qui seront cohérentes pour la même équipe
      newLat = 46.603354 + ((id % 1000) / 1000.0) * 8.0 - 4.0;
      newLng = 1.888334 + ((id % 500) / 500.0) * 8.0 - 4.0;
    }
    
    return Team(
      id: id,
      name: name,
      tla: tla,
      crest: crest,
      address: address,
      website: website,
      founded: founded,
      clubColors: clubColors,
      venue: venue,
      latitude: newLat,
      longitude: newLng,
    );
  }
  
  // Version synchrone pour la compatibilité avec le code existant
  Team withValidCoordinates() {
    // Si l'équipe a déjà des coordonnées valides, la retourner telle quelle
    if (latitude != null && longitude != null) {
      return this;
    }
    
    // Coordonnées par défaut (centre de la France)
    double newLat = 46.603354;
    double newLng = 1.888334;
    
    // Utiliser la méthode de secours basée sur les coordonnées connues
    // Coordonnées des principales équipes européennes
    Map<String, List<double>> teamCoordinates = {
      // France
      'Paris Saint-Germain': [48.8414, 2.2530],
      'Olympique de Marseille': [43.2696, 5.3950],
      'Olympique Lyonnais': [45.7653, 4.9822],
      'AS Monaco': [43.7272, 7.4154],
      'LOSC Lille': [50.6119, 3.1301],
      'Stade Rennais': [48.1073, -1.7107],
      'RC Lens': [50.4322, 2.8142],
      'OGC Nice': [43.7047, 7.1927],
      
      // Angleterre
      'Manchester United': [53.4631, -2.2913],
      'Manchester City': [53.4831, -2.2004],
      'Liverpool': [53.4308, -2.9608],
      'Chelsea': [51.4817, -0.1905],
      'Arsenal': [51.5549, -0.1084],
      'Tottenham': [51.6043, -0.0680],
      
      // Championship (Angleterre)
      'Norwich City FC': [52.6225, 1.3091],
      'Leeds United FC': [53.7772, -1.5724],
      'Sheffield United FC': [53.3703, -1.4705],
      'Middlesbrough FC': [54.5779, -1.2166],
      'Bristol City FC': [51.4400, -2.6206],
      
      // Espagne
      'Real Madrid': [40.4530, -3.6883],
      'Barcelona': [41.3809, 2.1228],
      'FC Barcelona': [41.3809, 2.1228], // Ajout du nom complet pour FC Barcelona
      'Atletico Madrid': [40.4361, -3.5994],
      'Sevilla': [37.3841, -5.9705],
      'Valencia': [39.4748, -0.3585],
      
      // Italie
      'Juventus': [45.1096, 7.6413],
      'Inter': [45.4781, 9.1240],
      'AC Milan': [45.4781, 9.1240],
      'Napoli': [40.8279, 14.1931],
      'Roma': [41.9341, 12.4547],
      
      // Allemagne
      'Bayern Munich': [48.2188, 11.6247],
      'Borussia Dortmund': [51.4926, 7.4518],
      'RB Leipzig': [51.3456, 12.3474],
      'Bayer Leverkusen': [51.0384, 7.0022],
    };
    
    // Vérifier si l'équipe est dans notre liste de coordonnées connues par son nom
    if (teamCoordinates.containsKey(name)) {
      newLat = teamCoordinates[name]![0];
      newLng = teamCoordinates[name]![1];
    } 
    // Vérifier par ID pour les équipes du Championship
    else if (id == 343) { // Norwich City
      newLat = 52.6225;
      newLng = 1.3091;
    } 
    else if (id == 341) { // Leeds United
      newLat = 53.7772;
      newLng = -1.5724;
    } 
    else if (id == 356) { // Sheffield United
      newLat = 53.3703;
      newLng = -1.4705;
    } 
    else if (id == 384) { // Middlesbrough
      newLat = 54.5779;
      newLng = -1.2166;
    } 
    else if (id == 387) { // Bristol City
      newLat = 51.4400;
      newLng = -2.6206;
    }
    // Essayer d'extraire un pays ou une ville de l'adresse
    else if (address != null && address!.isNotEmpty) {
      String addressLower = address!.toLowerCase();
      
      // Coordonnées approximatives des pays
      if (addressLower.contains('france')) {
        newLat = 46.603354; // Centre de la France
        newLng = 1.888334;
      } else if (addressLower.contains('england') || addressLower.contains('royaume-uni') || addressLower.contains('united kingdom')) {
        newLat = 51.5074; // Londres
        newLng = -0.1278;
      } else if (addressLower.contains('spain') || addressLower.contains('espagne')) {
        newLat = 40.4168; // Madrid
        newLng = -3.7038;
      } else if (addressLower.contains('italy') || addressLower.contains('italie')) {
        newLat = 41.9028; // Rome
        newLng = 12.4964;
      } else if (addressLower.contains('germany') || addressLower.contains('allemagne')) {
        newLat = 52.5200; // Berlin
        newLng = 13.4050;
      }
      
      // Ajouter un léger décalage pour éviter que toutes les équipes d'un même pays se superposent
      newLat += (id % 100) * 0.01;
      newLng += (id % 50) * 0.01;
    } else {
      // Si aucune information n'est disponible, utiliser l'ID pour générer des coordonnées
      // qui seront cohérentes pour la même équipe
      newLat = 46.603354 + ((id % 1000) / 1000.0) * 8.0 - 4.0;
      newLng = 1.888334 + ((id % 500) / 500.0) * 8.0 - 4.0;
    }
    
    return Team(
      id: id,
      name: name,
      tla: tla,
      crest: crest,
      address: address,
      website: website,
      founded: founded,
      clubColors: clubColors,
      venue: venue,
      latitude: newLat,
      longitude: newLng,
    );
  }
}
