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
  final String shopId;
  final String id ;
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
    required this.shopId,
    required this.id ,
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

      'shopId': shopId,
      'driverId':  driverId ??   '',
      'senderDetails': senderDetails.toJson(),
      'recipientDetails': recipientDetails.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'totalOrderPrice': totalOrderPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt== null ? null :   acceptedAt?.toIso8601String(),
      'pickedUpAt':   pickedUpAt == null ? null : pickedUpAt?.toIso8601String(),
      'deliveredAt':   deliveredAt == null ? null : deliveredAt?.toIso8601String(),
      'cancelledAt':   cancelledAt == null ? null : cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json , String docId) {
    return Order(
      shopId: json['shopId'],
      id :  docId ,
      driverId: json['driverId']??"",
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
