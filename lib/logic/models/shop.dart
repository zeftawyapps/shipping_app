// نموذج بيانات المتجر

import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';

import 'location.dart';

class Shop  extends BaseEntityDataModel {

  String  shopId = '';
  DateTime? createdAt = DateTime.now();
    String userName;
    String? shopName;
    String? address;
    Location? location;
    String? phone;
    String email;

    bool isActive;

  Shop({
    required this.shopId,
    this.shopName,
    required this.createdAt,
    required this.userName,
    required this.address,
      this.location,
    required this.phone,
    required this.email,

    required this.isActive,
  }) {
    id = shopId;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': shopId,
      'shopName': shopName,
      'name': userName,
      'address': address,
      'location': location?.toJson(),
      'phone': phone,
      'email': email,
      'createdAt':  new DateTime.now().toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json , String id )  {
    return Shop(
      shopId:  id ,

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
