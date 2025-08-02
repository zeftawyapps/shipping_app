// نموذج بيانات السائق

import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';
import 'location.dart';

enum DriverStatus { available, busy, at_rally_point }

class Driver implements BaseEntityDataModel {
  String? id ;
  final Location currentLocation;
  final DriverStatus status;
  final Location? rallyPoint;
  final DateTime lastLocationUpdate;
  final double rating;

  Driver({
    this.id ,
    required this.currentLocation,
    required this.status,
    this.rallyPoint,
    required this.lastLocationUpdate,
    required this.rating,
  }) {
    toJson();
  }

  Map<String, dynamic> toJson() {
    map = {
      'id': id ,
      'currentLocation': currentLocation.toJson(),
      'status': status.name,
      'rallyPoint': rallyPoint?.toJson(),
      'lastLocationUpdate': lastLocationUpdate.toIso8601String(),
      'rating': rating,
    };
    return map!;
  }

  factory Driver.fromJson(Map<String, dynamic> json, {String? id}) {
    return Driver(
      id : json['id'] ?? id ?? "",
      currentLocation: Location.fromJson(json['currentLocation']),
      status: DriverStatus.values.firstWhere((e) => e.name == json['status']),
      rallyPoint:
          json['rallyPoint'] != null
              ? Location.fromJson(json['rallyPoint'])
              : null,
      lastLocationUpdate: DateTime.parse(json['lastLocationUpdate'] ?? "2025-07-08T10:00:00Z"),
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic>? map;

  @override
  DateTime? createdAt;

  @override
  bool? isArchived;

  @override
  DateTime? updatedAt;
}
