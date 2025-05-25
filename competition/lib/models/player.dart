class Player {
  final int id;
  final String name;
  final String? position;
  final String? dateOfBirth;
  final String? nationality;
  final int? shirtNumber;
  final int teamId;
  final String? teamName;
  final String? imageUrl; // URL de l'image du joueur

  Player({
    required this.id,
    required this.name,
    this.position,
    this.dateOfBirth,
    this.nationality,
    this.shirtNumber,
    required this.teamId,
    this.teamName,
    this.imageUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json, {int? teamId, String? teamName}) {
    return Player(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      dateOfBirth: json['dateOfBirth'],
      nationality: json['nationality'],
      shirtNumber: json['shirtNumber'],
      teamId: teamId ?? json['teamId'] ?? 0,
      teamName: teamName ?? json['teamName'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
      'shirtNumber': shirtNumber,
      'teamId': teamId,
      'teamName': teamName,
    };
  }

  // For database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
      'shirtNumber': shirtNumber,
      'teamId': teamId,
      'teamName': teamName,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      dateOfBirth: map['dateOfBirth'],
      nationality: map['nationality'],
      shirtNumber: map['shirtNumber'],
      teamId: map['teamId'],
      teamName: map['teamName'],
    );
  }
}
