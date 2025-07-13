// نموذج بيانات المتجر

import 'location.dart';

class Shop {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final Location location;
  final String phone;
  final String email;
  final DateTime createdAt;
  final bool isActive;

  Shop({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.location,
    required this.phone,
    required this.email,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'location': location.toJson(),
      'phone': phone,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'],
      address: json['address'],
      location: Location.fromJson(json['location']),
      phone: json['phone'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }
}
