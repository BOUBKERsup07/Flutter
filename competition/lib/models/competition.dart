class Competition {
  final int id;
  final String name;
  final String code;
  final String type;
  final String emblem;
  final String? currentSeason;
  final int? numberOfAvailableSeasons;
  final String? area;

  Competition({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.emblem,
    this.currentSeason,
    this.numberOfAvailableSeasons,
    this.area,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      emblem: json['emblem'] ?? '',
      currentSeason: json['currentSeason'] != null 
          ? "${json['currentSeason']['startDate']} - ${json['currentSeason']['endDate']}"
          : null,
      numberOfAvailableSeasons: json['numberOfAvailableSeasons'],
      area: json['area'] != null ? json['area']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'emblem': emblem,
      'currentSeason': currentSeason,
      'numberOfAvailableSeasons': numberOfAvailableSeasons,
      'area': area,
    };
  }
}
