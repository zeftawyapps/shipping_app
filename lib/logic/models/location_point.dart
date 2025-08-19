// نموذج بيانات نقطة الموقع للخريطة

import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';
import 'location.dart';

enum LocationType {
  driver,
  shop,
  order_pickup,
  order_delivery,
}

// Abstract metadata class for location points
abstract class LocationMetadata {
  const LocationMetadata();
  
  Map<String, dynamic> toJson();
  
  factory LocationMetadata.fromJson(Map<String, dynamic> json, LocationType type) {
    switch (type) {
      case LocationType.driver:
        return DriverMetadata.fromJson(json);
      case LocationType.shop:
        return ShopMetadata.fromJson(json);
      case LocationType.order_pickup:
      case LocationType.order_delivery:
        return OrderMetadata.fromJson(json);
    }
  }
}

// Driver metadata model
class DriverMetadata extends LocationMetadata {
  final String? phone;
  final String? status;
  final double? rating;
  final String? vehicleType;
  final String? licenseNumber;

  const DriverMetadata({
    this.phone,
    this.status,
    this.rating,
    this.vehicleType,
    this.licenseNumber,
  });

  factory DriverMetadata.fromJson(Map<String, dynamic> json) {
    return DriverMetadata(
      phone: json['phone'],
      status: json['status'],
      rating: json['rating']?.toDouble(),
      vehicleType: json['vehicleType'],
      licenseNumber: json['licenseNumber'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'status': status,
      'rating': rating,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'type': 'driver',
    };
  }

  DriverMetadata copyWith({
    String? phone,
    String? status,
    double? rating,
    String? vehicleType,
    String? licenseNumber,
  }) {
    return DriverMetadata(
      phone: phone ?? this.phone,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      vehicleType: vehicleType ?? this.vehicleType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}

// Shop metadata model
class ShopMetadata extends LocationMetadata {
  final String? address;
  final String? phone;
  final String? category;
  final double? rating;
  final String? description;
  final bool? isActive;
  final String? workingHours;

  const ShopMetadata({
    this.address,
    this.phone,
    this.category,
    this.rating,
    this.description,
    this.isActive,
    this.workingHours,
  });

  factory ShopMetadata.fromJson(Map<String, dynamic> json) {
    return ShopMetadata(
      address: json['address'],
      phone: json['phone'],
      category: json['category'],
      rating: json['rating']?.toDouble(),
      description: json['description'],
      isActive: json['isActive'],
      workingHours: json['workingHours'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'phone': phone,
      'category': category,
      'rating': rating,
      'description': description,
      'isActive': isActive,
      'workingHours': workingHours,
      'type': 'shop',
    };
  }

  ShopMetadata copyWith({
    String? address,
    String? phone,
    String? category,
    double? rating,
    String? description,
    bool? isActive,
    String? workingHours,
  }) {
    return ShopMetadata(
      address: address ?? this.address,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}

// Order metadata model
class OrderMetadata extends LocationMetadata {
  final String? customerName;
  final String? shopName;
  final String? address;
  final String? phone;
  final String? orderStatus;
  final double? totalPrice;
  final String? priority;
  final String? estimatedTime;
  final DateTime? orderDate;

  const OrderMetadata({
    this.customerName,
    this.shopName,
    this.address,
    this.phone,
    this.orderStatus,
    this.totalPrice,
    this.priority,
    this.estimatedTime,
    this.orderDate,
  });

  factory OrderMetadata.fromJson(Map<String, dynamic> json) {
    return OrderMetadata(
      customerName: json['customerName'],
      shopName: json['shopName'],
      address: json['address'],
      phone: json['phone'],
      orderStatus: json['orderStatus'],
      totalPrice: json['totalPrice']?.toDouble(),
      priority: json['priority'],
      estimatedTime: json['estimatedTime'],
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'shopName': shopName,
      'address': address,
      'phone': phone,
      'orderStatus': orderStatus,
      'totalPrice': totalPrice,
      'priority': priority,
      'estimatedTime': estimatedTime,
      'orderDate': orderDate?.toIso8601String(),
      'type': 'order',
    };
  }

  OrderMetadata copyWith({
    String? customerName,
    String? shopName,
    String? address,
    String? phone,
    String? orderStatus,
    double? totalPrice,
    String? priority,
    String? estimatedTime,
    DateTime? orderDate,
  }) {
    return OrderMetadata(
      customerName: customerName ?? this.customerName,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      orderStatus: orderStatus ?? this.orderStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      priority: priority ?? this.priority,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      orderDate: orderDate ?? this.orderDate,
    );
  }
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

  @override
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

  // Enhanced JSON methods for specific types
  Map<String, dynamic> toDriverJson() {
    if (type != LocationType.driver) {
      throw ArgumentError('This method can only be called for driver type LocationPoints');
    }
    return {
      'driverId': entityId,
      'driverName': name,
      'location': location.toJson(),
      'phone': metadata?['phone'],
      'status': metadata?['status'],
      'rating': metadata?['rating'],
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toShopJson() {
    if (type != LocationType.shop) {
      throw ArgumentError('This method can only be called for shop type LocationPoints');
    }
    return {
      'shopId': entityId,
      'shopName': name,
      'location': location.toJson(),
      'address': description,
      'phone': metadata?['phone'],
      'isActive': metadata?['isActive'] ?? isActive,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toOrderJson() {
    if (type != LocationType.order_pickup && type != LocationType.order_delivery) {
      throw ArgumentError('This method can only be called for order type LocationPoints');
    }
    return {
      'orderId': entityId,
      'orderType': type.name,
      'location': location.toJson(),
      'customerName': metadata?['customerName'],
      'shopName': metadata?['shopName'],
      'address': metadata?['address'] ?? description,
      'phone': metadata?['phone'],
      'orderStatus': metadata?['orderStatus'],
      'totalPrice': metadata?['totalPrice'],
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
    DateTime? lastUpdated,
    bool isActive = true,
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
        'type': 'driver',
      },
      lastUpdated: lastUpdated ?? DateTime.now(),
      isActive: isActive,
    );
  }

  factory LocationPoint.fromShop({
    required String shopId,
    required String shopName,
    required Location location,
    String? address,
    String? phone,
    bool? isActive,
    DateTime? lastUpdated,
    Map<String, dynamic>? additionalData,
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
        'type': 'shop',
        ...?additionalData,
      },
      lastUpdated: lastUpdated ?? DateTime.now(),
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
    DateTime? lastUpdated,
    Map<String, dynamic>? additionalData,
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
        'type': 'order_pickup',
        ...?additionalData,
      },
      lastUpdated: lastUpdated ?? DateTime.now(),
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
    DateTime? lastUpdated,
    Map<String, dynamic>? additionalData,
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
        'type': 'order_delivery',
        ...?additionalData,
      },
      lastUpdated: lastUpdated ?? DateTime.now(),
      isActive: true,
    );
  }

  // Enhanced factory constructors from JSON data
  factory LocationPoint.driverFromJson(Map<String, dynamic> json) {
    return LocationPoint.fromDriver(
      driverId: json['driverId'] ?? json['id'] ?? '',
      driverName: json['driverName'] ?? json['name'] ?? '',
      location: Location.fromJson(json['location']),
      phone: json['phone'],
      status: json['status'],
      rating: json['rating']?.toDouble(),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  factory LocationPoint.shopFromJson(Map<String, dynamic> json) {
    return LocationPoint.fromShop(
      shopId: json['shopId'] ?? json['id'] ?? '',
      shopName: json['shopName'] ?? json['name'] ?? '',
      location: Location.fromJson(json['location']),
      address: json['address'],
      phone: json['phone'],
      isActive: json['isActive'],
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      additionalData: {
        if (json['category'] != null) 'category': json['category'],
        if (json['rating'] != null) 'rating': json['rating'],
        if (json['description'] != null) 'description': json['description'],
      },
    );
  }

  factory LocationPoint.orderFromJson(Map<String, dynamic> json) {
    final orderType = json['orderType'] ?? 'order_pickup';
    
    if (orderType == 'order_pickup') {
      return LocationPoint.fromOrderPickup(
        orderId: json['orderId'] ?? json['id'] ?? '',
        shopName: json['shopName'] ?? '',
        location: Location.fromJson(json['location']),
        customerName: json['customerName'],
        orderStatus: json['orderStatus'],
        totalPrice: json['totalPrice']?.toDouble(),
        lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
        additionalData: {
          if (json['priority'] != null) 'priority': json['priority'],
          if (json['estimatedTime'] != null) 'estimatedTime': json['estimatedTime'],
        },
      );
    } else {
      return LocationPoint.fromOrderDelivery(
        orderId: json['orderId'] ?? json['id'] ?? '',
        customerName: json['customerName'] ?? '',
        location: Location.fromJson(json['location']),
        address: json['address'],
        phone: json['phone'],
        orderStatus: json['orderStatus'],
        totalPrice: json['totalPrice']?.toDouble(),
        lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
        additionalData: {
          if (json['priority'] != null) 'priority': json['priority'],
          if (json['estimatedTime'] != null) 'estimatedTime': json['estimatedTime'],
        },
      );
    }
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

  // Utility methods for data manipulation
  LocationPoint copyWith({
    String? locationId,
    String? name,
    String? description,
    Location? location,
    LocationType? type,
    String? entityId,
    Map<String, dynamic>? metadata,
    DateTime? lastUpdated,
    bool? isActive,
  }) {
    return LocationPoint(
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      metadata: metadata ?? this.metadata,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
  }

  // Update metadata
  void updateMetadata(Map<String, dynamic> newMetadata) {
    metadata = {...?metadata, ...newMetadata};
    lastUpdated = DateTime.now();
  }

  // Update specific driver data
  void updateDriverData({
    String? phone,
    String? status,
    double? rating,
  }) {
    if (type != LocationType.driver) {
      throw ArgumentError('This method can only be called for driver type LocationPoints');
    }
    updateMetadata({
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
    });
  }

  // Update specific shop data
  void updateShopData({
    String? address,
    String? phone,
    bool? isActive,
  }) {
    if (type != LocationType.shop) {
      throw ArgumentError('This method can only be called for shop type LocationPoints');
    }
    updateMetadata({
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (isActive != null) 'isActive': isActive,
    });
    if (isActive != null) {
      this.isActive = isActive;
    }
  }

  // Update specific order data
  void updateOrderData({
    String? customerName,
    String? shopName,
    String? address,
    String? phone,
    String? orderStatus,
    double? totalPrice,
  }) {
    if (type != LocationType.order_pickup && type != LocationType.order_delivery) {
      throw ArgumentError('This method can only be called for order type LocationPoints');
    }
    updateMetadata({
      if (customerName != null) 'customerName': customerName,
      if (shopName != null) 'shopName': shopName,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (orderStatus != null) 'orderStatus': orderStatus,
      if (totalPrice != null) 'totalPrice': totalPrice,
    });
  }

  // Convert to specific type JSON based on current type
  Map<String, dynamic> toSpecificJson() {
    switch (type) {
      case LocationType.driver:
        return toDriverJson();
      case LocationType.shop:
        return toShopJson();
      case LocationType.order_pickup:
      case LocationType.order_delivery:
        return toOrderJson();
    }
  }

  @override
  String toString() {
    return 'LocationPoint{locationId: $locationId, name: $name, type: $type, location: $location, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationPoint &&
        other.locationId == locationId &&
        other.entityId == entityId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return locationId.hashCode ^ entityId.hashCode ^ type.hashCode;
  }
}
