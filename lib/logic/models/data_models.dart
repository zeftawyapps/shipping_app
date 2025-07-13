// نماذج البيانات لنظام إدارة توصيل الطلبات

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String passwordHash;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'passwordHash': passwordHash,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      passwordHash: json['passwordHash'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'],
    );
  }
}

enum UserRole { admin, driver, shop_owner }

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}

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

enum DriverStatus { available, busy, at_rally_point }

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      name: json['name'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
    );
  }
}

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

class Order {
  final String id;
  final String shopId;
  final String? driverId;
  final ContactDetails senderDetails;
  final ContactDetails recipientDetails;
  final List<OrderItem> items;
  final double totalOrderPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  Order({
    required this.id,
    required this.shopId,
    this.driverId,
    required this.senderDetails,
    required this.recipientDetails,
    required this.items,
    required this.totalOrderPrice,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'driverId': driverId,
      'senderDetails': senderDetails.toJson(),
      'recipientDetails': recipientDetails.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalOrderPrice': totalOrderPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      shopId: json['shopId'],
      driverId: json['driverId'],
      senderDetails: ContactDetails.fromJson(json['senderDetails']),
      recipientDetails: ContactDetails.fromJson(json['recipientDetails']),
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      totalOrderPrice: json['totalOrderPrice'].toDouble(),
      status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      acceptedAt:
          json['acceptedAt'] != null
              ? DateTime.parse(json['acceptedAt'])
              : null,
      pickedUpAt:
          json['pickedUpAt'] != null
              ? DateTime.parse(json['pickedUpAt'])
              : null,
      deliveredAt:
          json['deliveredAt'] != null
              ? DateTime.parse(json['deliveredAt'])
              : null,
      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.parse(json['cancelledAt'])
              : null,
      cancellationReason: json['cancellationReason'],
    );
  }
}

enum OrderStatus {
  pending_acceptance,
  accepted,
  picked_up,
  on_the_way,
  delivered,
  cancelled,
}

// إضافة نموذج للإحصائيات
class OrderStatistics {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int activeOrders;
  final double completionRate;
  final double cancellationRate;

  OrderStatistics({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.activeOrders,
    required this.completionRate,
    required this.cancellationRate,
  });
}

class DriverStatistics {
  final int totalDrivers;
  final int availableDrivers;
  final int busyDrivers;
  final int atRallyPointDrivers;

  DriverStatistics({
    required this.totalDrivers,
    required this.availableDrivers,
    required this.busyDrivers,
    required this.atRallyPointDrivers,
  });
}
