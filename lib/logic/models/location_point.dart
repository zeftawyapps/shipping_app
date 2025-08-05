// نموذج بيانات نقطة الموقع للخريطة

import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';
import 'location.dart';

enum LocationType {
  driver,
  shop,
  order_pickup,
  order_delivery,
}

class LocationPoint extends BaseEntityDataModel {
  String locationId;
  String name;
  String? description;
  Location location;
  LocationType type;
  String? entityId; // ID of the related driver, shop, or order
  Map<String, dynamic>? metadata; // Additional data based on type
  DateTime lastUpdated;
  bool isActive;

  LocationPoint({
    required this.locationId,
    required this.name,
    this.description,
    required this.location,
    required this.type,
    this.entityId,
    this.metadata,
    required this.lastUpdated,
    this.isActive = true,
  }) {
    id = locationId;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': locationId,
      'name': name,
      'description': description,
      'location': location.toJson(),
      'type': type.name,
      'entityId': entityId,
      'metadata': metadata,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json, String id) {
    return LocationPoint(
      locationId: id,
      name: json['name'] ?? '',
      description: json['description'],
      location: Location.fromJson(json['location']),
      type: LocationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LocationType.driver,
      ),
      entityId: json['entityId'],
      metadata: json['metadata'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'] ?? true,
    );
  }

  // Factory constructors for specific types
  factory LocationPoint.fromDriver({
    required String driverId,
    required String driverName,
    required Location location,
    String? phone,
    String? status,
    double? rating,
  }) {
    return LocationPoint(
      locationId: 'driver_$driverId',
      name: driverName,
      description: 'سائق',
      location: location,
      type: LocationType.driver,
      entityId: driverId,
      metadata: {
        'phone': phone,
        'status': status,
        'rating': rating,
      },
      lastUpdated: DateTime.now(),
      isActive: true,
    );
  }

  factory LocationPoint.fromShop({
    required String shopId,
    required String shopName,
    required Location location,
    String? address,
    String? phone,
    bool? isActive,
  }) {
    return LocationPoint(
      locationId: 'shop_$shopId',
      name: shopName,
      description: address ?? 'محل',
      location: location,
      type: LocationType.shop,
      entityId: shopId,
      metadata: {
        'address': address,
        'phone': phone,
        'isActive': isActive,
      },
      lastUpdated: DateTime.now(),
      isActive: isActive ?? true,
    );
  }

  factory LocationPoint.fromOrderPickup({
    required String orderId,
    required String shopName,
    required Location location,
    String? customerName,
    String? orderStatus,
    double? totalPrice,
  }) {
    return LocationPoint(
      locationId: 'order_pickup_$orderId',
      name: 'استلام من $shopName',
      description: 'نقطة استلام الطلب',
      location: location,
      type: LocationType.order_pickup,
      entityId: orderId,
      metadata: {
        'shopName': shopName,
        'customerName': customerName,
        'orderStatus': orderStatus,
        'totalPrice': totalPrice,
      },
      lastUpdated: DateTime.now(),
      isActive: true,
    );
  }

  factory LocationPoint.fromOrderDelivery({
    required String orderId,
    required String customerName,
    required Location location,
    String? address,
    String? phone,
    String? orderStatus,
    double? totalPrice,
  }) {
    return LocationPoint(
      locationId: 'order_delivery_$orderId',
      name: 'توصيل إلى $customerName',
      description: address ?? 'نقطة توصيل الطلب',
      location: location,
      type: LocationType.order_delivery,
      entityId: orderId,
      metadata: {
        'customerName': customerName,
        'address': address,
        'phone': phone,
        'orderStatus': orderStatus,
        'totalPrice': totalPrice,
      },
      lastUpdated: DateTime.now(),
      isActive: true,
    );
  }

  // Helper getters
  String get typeDisplayName {
    switch (type) {
      case LocationType.driver:
        return 'سائق';
      case LocationType.shop:
        return 'محل';
      case LocationType.order_pickup:
        return 'استلام طلب';
      case LocationType.order_delivery:
        return 'توصيل طلب';
    }
  }

  String get statusText {
    switch (type) {
      case LocationType.driver:
        return metadata?['status'] ?? 'غير محدد';
      case LocationType.shop:
        return (metadata?['isActive'] == true) ? 'نشط' : 'غير نشط';
      case LocationType.order_pickup:
      case LocationType.order_delivery:
        return metadata?['orderStatus'] ?? 'غير محدد';
    }
  }

  String? get phoneNumber {
    return metadata?['phone'];
  }

  double? get rating {
    return metadata?['rating'];
  }

  double? get totalPrice {
    return metadata?['totalPrice'];
  }
}
