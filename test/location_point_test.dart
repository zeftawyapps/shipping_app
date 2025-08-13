import 'package:flutter_test/flutter_test.dart';
import 'package:shipping_app/logic/models/location_point.dart';
import 'package:shipping_app/logic/models/location.dart';

void main() {
  group('LocationPoint Tests', () {
    test('Create driver LocationPoint and convert to JSON', () {
      final driverLocation = LocationPoint.fromDriver(
        driverId: 'driver_123',
        driverName: 'أحمد محمد',
        location: Location(latitude: 24.7136, longitude: 46.6753),
        phone: '+966501234567',
        status: 'متاح',
        rating: 4.5,
      );

      expect(driverLocation.type, LocationType.driver);
      expect(driverLocation.name, 'أحمد محمد');
      expect(driverLocation.phoneNumber, '+966501234567');
      expect(driverLocation.rating, 4.5);

      final json = driverLocation.toDriverJson();
      expect(json['driverId'], 'driver_123');
      expect(json['driverName'], 'أحمد محمد');
      expect(json['phone'], '+966501234567');
      expect(json['status'], 'متاح');
      expect(json['rating'], 4.5);
    });

    test('Create shop LocationPoint and convert to JSON', () {
      final shopLocation = LocationPoint.fromShop(
        shopId: 'shop_456',
        shopName: 'مطعم الحبايب',
        location: Location(latitude: 24.7000, longitude: 46.6800),
        address: 'شارع الملك فهد، الرياض',
        phone: '+966112345678',
        isActive: true,
      );

      expect(shopLocation.type, LocationType.shop);
      expect(shopLocation.name, 'مطعم الحبايب');
      expect(shopLocation.description, 'شارع الملك فهد، الرياض');
      expect(shopLocation.phoneNumber, '+966112345678');

      final json = shopLocation.toShopJson();
      expect(json['shopId'], 'shop_456');
      expect(json['shopName'], 'مطعم الحبايب');
      expect(json['address'], 'شارع الملك فهد، الرياض');
      expect(json['phone'], '+966112345678');
      expect(json['isActive'], true);
    });

    test('Create order pickup LocationPoint and convert to JSON', () {
      final orderLocation = LocationPoint.fromOrderPickup(
        orderId: 'order_789',
        shopName: 'مطعم الحبايب',
        location: Location(latitude: 24.7000, longitude: 46.6800),
        customerName: 'فاطمة أحمد',
        orderStatus: 'قيد التحضير',
        totalPrice: 85.50,
      );

      expect(orderLocation.type, LocationType.order_pickup);
      expect(orderLocation.name, 'استلام من مطعم الحبايب');
      expect(orderLocation.totalPrice, 85.50);

      final json = orderLocation.toOrderJson();
      expect(json['orderId'], 'order_789');
      expect(json['orderType'], 'order_pickup');
      expect(json['customerName'], 'فاطمة أحمد');
      expect(json['shopName'], 'مطعم الحبايب');
      expect(json['orderStatus'], 'قيد التحضير');
      expect(json['totalPrice'], 85.50);
    });

    test('Create order delivery LocationPoint and convert to JSON', () {
      final deliveryLocation = LocationPoint.fromOrderDelivery(
        orderId: 'order_789',
        customerName: 'فاطمة أحمد',
        location: Location(latitude: 24.6800, longitude: 46.7200),
        address: 'حي العليا، الرياض',
        phone: '+966501111111',
        orderStatus: 'في الطريق',
        totalPrice: 85.50,
      );

      expect(deliveryLocation.type, LocationType.order_delivery);
      expect(deliveryLocation.name, 'توصيل إلى فاطمة أحمد');
      expect(deliveryLocation.description, 'حي العليا، الرياض');
      expect(deliveryLocation.phoneNumber, '+966501111111');

      final json = deliveryLocation.toOrderJson();
      expect(json['orderId'], 'order_789');
      expect(json['orderType'], 'order_delivery');
      expect(json['customerName'], 'فاطمة أحمد');
      expect(json['address'], 'حي العليا، الرياض');
      expect(json['phone'], '+966501111111');
      expect(json['orderStatus'], 'في الطريق');
      expect(json['totalPrice'], 85.50);
    });

    test('Create LocationPoint from JSON data', () {
      // Test driver from JSON
      final driverJson = {
        'driverId': 'driver_123',
        'driverName': 'أحمد محمد',
        'location': {'latitude': 24.7136, 'longitude': 46.6753},
        'phone': '+966501234567',
        'status': 'متاح',
        'rating': 4.5,
        'isActive': true,
      };

      final driverFromJson = LocationPoint.driverFromJson(driverJson);
      expect(driverFromJson.type, LocationType.driver);
      expect(driverFromJson.name, 'أحمد محمد');
      expect(driverFromJson.entityId, 'driver_123');
      expect(driverFromJson.rating, 4.5);

      // Test shop from JSON
      final shopJson = {
        'shopId': 'shop_456',
        'shopName': 'مطعم الحبايب',
        'location': {'latitude': 24.7000, 'longitude': 46.6800},
        'address': 'شارع الملك فهد، الرياض',
        'phone': '+966112345678',
        'isActive': true,
      };

      final shopFromJson = LocationPoint.shopFromJson(shopJson);
      expect(shopFromJson.type, LocationType.shop);
      expect(shopFromJson.name, 'مطعم الحبايب');
      expect(shopFromJson.entityId, 'shop_456');
    });

    test('Update LocationPoint data', () {
      final driverLocation = LocationPoint.fromDriver(
        driverId: 'driver_123',
        driverName: 'أحمد محمد',
        location: Location(latitude: 24.7136, longitude: 46.6753),
        phone: '+966501234567',
        status: 'متاح',
        rating: 4.5,
      );

      // Update driver data
      driverLocation.updateDriverData(
        status: 'مشغول',
        rating: 4.8,
      );

      expect(driverLocation.metadata?['status'], 'مشغول');
      expect(driverLocation.metadata?['rating'], 4.8);
      expect(driverLocation.rating, 4.8);
    });

    test('Copy LocationPoint with new data', () {
      final originalLocation = LocationPoint.fromDriver(
        driverId: 'driver_123',
        driverName: 'أحمد محمد',
        location: Location(latitude: 24.7136, longitude: 46.6753),
      );

      final copiedLocation = originalLocation.copyWith(
        name: 'أحمد علي',
        isActive: false,
      );

      expect(copiedLocation.name, 'أحمد علي');
      expect(copiedLocation.isActive, false);
      expect(copiedLocation.entityId, 'driver_123'); // Should remain the same
      expect(originalLocation.name, 'أحمد محمد'); // Original should be unchanged
    });
  });
}
