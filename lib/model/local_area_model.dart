class LocalAreaModel {
  const LocalAreaModel({
    required this.id,
    required this.areaName,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String areaName;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  String get displayName => city.isEmpty ? areaName : '$areaName, $city';

  factory LocalAreaModel.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int integer(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return LocalAreaModel(
      id: integer(json['id']),
      areaName: (json['area_name'] ?? json['areaName'] ?? '').toString().trim(),
      city: (json['city'] ?? '').toString().trim(),
      state: (json['state'] ?? '').toString().trim(),
      latitude: number(json['latitude']),
      longitude: number(json['longitude']),
    );
  }
}
