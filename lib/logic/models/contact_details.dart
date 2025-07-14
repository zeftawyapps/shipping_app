// نموذج بيانات تفاصيل الاتصال

import 'location.dart';

class ContactDetails {
  final String name;
  final String phone;
  final String? email;
  final Location location;

  ContactDetails({
    required this.name,
    required this.phone,
    this.email,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'location': location.toJson(),
    };
  }

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      location: Location.fromJson(json['location']),
    );
  }
}
