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

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      tla: json['tla'] ?? '',
      crest: json['crest'],
      address: json['address'],
      website: json['website'],
      founded: json['founded'],
      clubColors: json['clubColors'],
      venue: json['venue'],
      // In a real app, you would get these from a geocoding service
      // based on the team's address or venue
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

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

  // For database operations
  Map<String, dynamic> toMap() {
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

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      tla: map['tla'],
      crest: map['crest'],
      address: map['address'],
      website: map['website'],
      founded: map['founded'],
      clubColors: map['clubColors'],
      venue: map['venue'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
