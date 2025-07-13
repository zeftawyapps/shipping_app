// نموذج بيانات السائق

import 'location.dart';

enum DriverStatus { available, busy, at_rally_point }

class Driver {
  final String id;
  final Location currentLocation;
  final DriverStatus status;
  final Location? rallyPoint;
  final DateTime lastLocationUpdate;
  final double rating;

  Driver({
    required this.id,
    required this.currentLocation,
    required this.status,
    this.rallyPoint,
    required this.lastLocationUpdate,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentLocation': currentLocation.toJson(),
      'status': status.name,
      'rallyPoint': rallyPoint?.toJson(),
      'lastLocationUpdate': lastLocationUpdate.toIso8601String(),
      'rating': rating,
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      currentLocation: Location.fromJson(json['currentLocation']),
      status: DriverStatus.values.firstWhere((e) => e.name == json['status']),
      rallyPoint:
          json['rallyPoint'] != null
              ? Location.fromJson(json['rallyPoint'])
              : null,
      lastLocationUpdate: DateTime.parse(json['lastLocationUpdate']),
      rating: json['rating'].toDouble(),
    );
  }
}
