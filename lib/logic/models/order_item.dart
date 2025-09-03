// نموذج بيانات عنصر الطلب

import 'dart:math';

class OrderItem {
  final String id;
  final String name;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double? weight;

  OrderItem({
    String? id,
    required this.name,
    this.description,
    required this.quantity,
    required this.unitPrice,
    this.weight =0.5,
  }) : id = id ?? _generateId();

  // Generate ID using milliseconds + random number * 1000
  static String _generateId() {
    final random = Random();
    final randomNumber = random.nextInt(1000);
    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    return "item${milliseconds + (randomNumber * 1000)}";
  }

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'weight': weight ?? 0.5,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      weight: json['weight']?.toDouble(),
    );
  }
}
