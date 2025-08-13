import 'package:flutter/material.dart';
import '../../../../logic/models/models.dart';
import '../../../../logic/models/location_point.dart';

class MapUtils {
  // Location type utilities
  static Color getLocationTypeColor(LocationType type) {
    switch (type) {
      case LocationType.driver:
        return Colors.blue;
      case LocationType.shop:
        return Colors.green;
      case LocationType.order_pickup:
        return Colors.orange;
      case LocationType.order_delivery:
        return Colors.red;
    }
  }

  static IconData getLocationTypeIcon(LocationType type) {
    switch (type) {
      case LocationType.driver:
        return Icons.drive_eta;
      case LocationType.shop:
        return Icons.store;
      case LocationType.order_pickup:
        return Icons.call_received;
      case LocationType.order_delivery:
        return Icons.call_made;
    }
  }

  static String getLocationTypeDisplayName(LocationType type) {
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

  // Status utilities
  static String getDriverStatusName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  static String getOrderStatusName(OrderStatus status) {
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

  // Formatting utilities
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} ج.م';
  }

  static String formatRating(double rating) {
    return '${rating.toStringAsFixed(1)} / 5.0';
  }
}
