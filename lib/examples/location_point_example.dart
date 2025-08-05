// مثال على كيفية استخدام نظام نقاط الموقع الجديد

import 'package:shipping_app/logic/models/models.dart';
import 'package:shipping_app/logic/data/sample_data.dart';

void demonstrateLocationPointSystem() {
  print('=== مثال على نظام نقاط الموقع ===');
  
  // 1. إنشاء نقطة موقع للسائق
  final driver = SampleDataProvider.getDrivers().first;
  final driverLocationPoint = LocationPoint.fromDriver(
    driverId: driver.id!,
    driverName: driver.name ?? 'سائق غير محدد',
    location: driver.currentLocation!,
    phone: driver.phone,
    status: 'متاح',
    rating: driver.rating,
  );
  
  print('نقطة موقع السائق: ${driverLocationPoint.name}');
  print('النوع: ${driverLocationPoint.typeDisplayName}');
  print('الموقع: ${driverLocationPoint.location.latitude}, ${driverLocationPoint.location.longitude}');
  print('الحالة: ${driverLocationPoint.statusText}');
  print('التقييم: ${driverLocationPoint.rating}');
  print('---');
  
  // 2. إنشاء نقطة موقع للمحل
  final shop = SampleDataProvider.getShops().first;
  final shopLocationPoint = LocationPoint.fromShop(
    shopId: shop.shopId,
    shopName: shop.userName,
    location: shop.location!,
    address: shop.address,
    phone: shop.phone,
    isActive: shop.isActive,
  );
  
  print('نقطة موقع المحل: ${shopLocationPoint.name}');
  print('النوع: ${shopLocationPoint.typeDisplayName}');
  print('العنوان: ${shopLocationPoint.description}');
  print('الحالة: ${shopLocationPoint.statusText}');
  print('الهاتف: ${shopLocationPoint.phoneNumber}');
  print('---');
  
  // 3. إنشاء نقطة موقع لاستلام الطلب
  final order = SampleDataProvider.getOrders().first;
  final pickupLocationPoint = LocationPoint.fromOrderPickup(
    orderId: order.shopId,
    shopName: shop.userName,
    location: order.senderDetails.location,
    customerName: order.recipientDetails.name,
    orderStatus: 'في الطريق',
    totalPrice: order.totalOrderPrice,
  );
  
  print('نقطة استلام الطلب: ${pickupLocationPoint.name}');
  print('النوع: ${pickupLocationPoint.typeDisplayName}');
  print('الحالة: ${pickupLocationPoint.statusText}');
  print('السعر: ${pickupLocationPoint.totalPrice} ج.م');
  print('---');
  
  // 4. إنشاء نقطة موقع لتوصيل الطلب
  final deliveryLocationPoint = LocationPoint.fromOrderDelivery(
    orderId: order.shopId,
    customerName: order.recipientDetails.name,
    location: order.recipientDetails.location,
    address: order.recipientDetails.address,
    phone: order.recipientDetails.phone,
    orderStatus: 'في الطريق',
    totalPrice: order.totalOrderPrice,
  );
  
  print('نقطة توصيل الطلب: ${deliveryLocationPoint.name}');
  print('النوع: ${deliveryLocationPoint.typeDisplayName}');
  print('العنوان: ${deliveryLocationPoint.description}');
  print('الهاتف: ${deliveryLocationPoint.phoneNumber}');
  print('السعر: ${deliveryLocationPoint.totalPrice} ج.م');
  print('---');
  
  // 5. مثال على تجميع جميع النقاط
  final allLocationPoints = <LocationPoint>[
    driverLocationPoint,
    shopLocationPoint,
    pickupLocationPoint,
    deliveryLocationPoint,
  ];
  
  print('إجمالي نقاط الموقع: ${allLocationPoints.length}');
  
  // 6. فلترة النقاط حسب النوع
  final driverPoints = allLocationPoints.where((p) => p.type == LocationType.driver).toList();
  final shopPoints = allLocationPoints.where((p) => p.type == LocationType.shop).toList();
  final orderPoints = allLocationPoints.where((p) => 
    p.type == LocationType.order_pickup || p.type == LocationType.order_delivery).toList();
    
  print('نقاط السائقين: ${driverPoints.length}');
  print('نقاط المحلات: ${shopPoints.length}');
  print('نقاط الطلبات: ${orderPoints.length}');
  print('---');
  
  // 7. مثال على تحويل إلى JSON
  final locationPointJson = driverLocationPoint.toJson();
  print('نقطة الموقع كـ JSON:');
  locationPointJson.forEach((key, value) {
    print('  $key: $value');
  });
  print('---');
  
  // 8. مثال على إنشاء نقطة موقع من JSON
  final recreatedLocationPoint = LocationPoint.fromJson(locationPointJson, driverLocationPoint.locationId);
  print('النقطة المُعاد إنشاؤها: ${recreatedLocationPoint.name}');
  print('نفس البيانات: ${recreatedLocationPoint.locationId == driverLocationPoint.locationId}');
  
  print('=== انتهى المثال ===');
}

// مثال على كيفية استخدام النظام في واجهة الخريطة
class LocationPointsExample {
  static List<LocationPoint> getAllLocationPointsForMap() {
    final List<LocationPoint> points = [];
    
    // إضافة نقاط السائقين
    final drivers = SampleDataProvider.getDrivers();
    for (final driver in drivers) {
      if (driver.currentLocation != null) {
        points.add(LocationPoint.fromDriver(
          driverId: driver.id!,
          driverName: driver.name ?? 'سائق غير محدد',
          location: driver.currentLocation!,
          phone: driver.phone,
          status: _getDriverStatusName(driver.status),
          rating: driver.rating,
        ));
      }
    }
    
    // إضافة نقاط المحلات
    final shops = SampleDataProvider.getShops();
    for (final shop in shops) {
      if (shop.location != null) {
        points.add(LocationPoint.fromShop(
          shopId: shop.shopId,
          shopName: shop.userName,
          location: shop.location!,
          address: shop.address,
          phone: shop.phone,
          isActive: shop.isActive,
        ));
      }
    }
    
    // إضافة نقاط الطلبات
    final orders = SampleDataProvider.getOrders();
    for (final order in orders) {
      // نقطة الاستلام
      final shop = SampleDataProvider.getShopById(order.shopId);
      if (shop?.location != null) {
        points.add(LocationPoint.fromOrderPickup(
          orderId: order.shopId,
          shopName: shop!.userName,
          location: shop.location!,
          customerName: order.recipientDetails.name,
          orderStatus: _getOrderStatusName(order.status),
          totalPrice: order.totalOrderPrice,
        ));
      }
      
      // نقطة التوصيل
      points.add(LocationPoint.fromOrderDelivery(
        orderId: order.shopId,
        customerName: order.recipientDetails.name,
        location: order.recipientDetails.location,
        address: order.recipientDetails.address,
        phone: order.recipientDetails.phone,
        orderStatus: _getOrderStatusName(order.status),
        totalPrice: order.totalOrderPrice,
      ));
    }
    
    return points;
  }
  
  static List<LocationPoint> filterLocationPoints({
    required List<LocationPoint> points,
    LocationType? type,
    bool? isActive,
    String? searchTerm,
  }) {
    return points.where((point) {
      bool typeMatch = type == null || point.type == type;
      bool activeMatch = isActive == null || point.isActive == isActive;
      bool searchMatch = searchTerm == null || 
        point.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
        (point.description?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false);
      
      return typeMatch && activeMatch && searchMatch;
    }).toList();
  }
  
  static String _getDriverStatusName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }
  
  static String _getOrderStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return 'في انتظار القبول';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.picked_up:
        return 'تم الاستلام';
      case OrderStatus.on_the_way:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }
}
