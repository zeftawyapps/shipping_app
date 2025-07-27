// نموذج بيانات الطلب

import 'package:JoDija_reposatory/utilis/models/base_data_model.dart';

import 'order_item.dart';
import 'contact_details.dart';

enum OrderStatus  {
  pending_acceptance,
  accepted,
  picked_up,
  on_the_way,
  delivered,
  cancelled,
}

class Order  extends BaseEntityDataModel {
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
