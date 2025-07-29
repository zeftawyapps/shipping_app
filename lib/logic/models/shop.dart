// نموذج بيانات المتجر

import 'location.dart';

class Shop {
    String id;

    String userName;
    String? shopName;
    String? address;
    Location? location;
    String? phone;
    String email;
    DateTime createdAt;
    bool isActive;

  Shop({
    required this.id,
    this.shopName,

    required this.userName,
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
      'shopName': shopName,
      'name': userName,
      'address': address,
      'location': location?.toJson(),
      'phone': phone,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json , String id )  {
    return Shop(
      id:  id ,
      shopName: json['shopName'],
      userName: json['name'],
      address: json['address'],
      location:json['location'] == null ?  null  :    Location.fromJson(json['location']),
      phone: json['phone'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }
}
