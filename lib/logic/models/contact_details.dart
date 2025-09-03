// نموذج بيانات تفاصيل الاتصال

import 'location.dart';

class ContactDetails {
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double latitude;
  final double longitude;
  final String? notes;

  ContactDetails({
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  // Getter to maintain backward compatibility for location
  Location get location => Location(latitude: latitude, longitude: longitude);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes??'',
    };
  }

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      notes: json['notes']??'',
    );
  }
}
