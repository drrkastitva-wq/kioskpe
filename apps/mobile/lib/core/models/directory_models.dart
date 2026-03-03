class CourtModel {
  final String id;
  final String name;
  final String level; // district, high_court, supreme_court, tribunal
  final String state;
  final String? district;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? contactNumber;
  final String? website;

  CourtModel({
    required this.id,
    required this.name,
    required this.level,
    required this.state,
    this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.contactNumber,
    this.website,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      state: json['state'] ?? '',
      district: json['district'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactNumber: json['contactNumber'] ?? json['contact_number'],
      website: json['website'],
    );
  }
}

class PoliceStationModel {
  final String id;
  final String name;
  final String state;
  final String? district;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? contactNumber;

  PoliceStationModel({
    required this.id,
    required this.name,
    required this.state,
    this.district,
    this.address,
    this.latitude,
    this.longitude,
    this.contactNumber,
  });

  factory PoliceStationModel.fromJson(Map<String, dynamic> json) {
    return PoliceStationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      district: json['district'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactNumber: json['contactNumber'] ?? json['contact_number'],
    );
  }
}

class BarAssociationModel {
  final String id;
  final String name;
  final String state;
  final String? district;
  final String? address;
  final String? contactNumber;
  final String? website;

  BarAssociationModel({
    required this.id,
    required this.name,
    required this.state,
    this.district,
    this.address,
    this.contactNumber,
    this.website,
  });

  factory BarAssociationModel.fromJson(Map<String, dynamic> json) {
    return BarAssociationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      district: json['district'],
      address: json['address'],
      contactNumber: json['contactNumber'] ?? json['contact_number'],
      website: json['website'],
    );
  }
}
