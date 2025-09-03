// Test example to verify the new OrderItem JSON structure
import 'dart:convert';
import 'package:shipping_app/logic/models/order_item.dart';

void main() {
  // Test the example JSON structure you provided
  final exampleJson = {
    "id": "item1",
    "name": "Electronics Package",
    "description": "Smartphone and accessories",
    "quantity": 1,
    "unitPrice": 500,
    "weight": 0.5
  };

  // Test fromJson
  final orderItem = OrderItem.fromJson(exampleJson);
  print('Parsed from JSON:');
  print('ID: ${orderItem.id}');
  print('Name: ${orderItem.name}');
  print('Description: ${orderItem.description}');
  print('Quantity: ${orderItem.quantity}');
  print('Unit Price: ${orderItem.unitPrice}');
  print('Weight: ${orderItem.weight}');
  print('Total Price: ${orderItem.totalPrice}');

  // Test creating a new OrderItem (with auto-generated ID)
  final newItem = OrderItem(
    name: "Test Product",
    description: "A test product description",
    quantity: 2,
    unitPrice: 25.50,
    weight: 1.2,
  );

  print('\nNew OrderItem with auto-generated ID:');
  print('ID: ${newItem.id}');
  print('Name: ${newItem.name}');
  print('Description: ${newItem.description}');
  print('Total Price: ${newItem.totalPrice}');

  // Test toJson
  final outputJson = newItem.toJson();
  print('\nSerialized to JSON:');
  print(JsonEncoder.withIndent('  ').convert(outputJson));

  // Verify the structure matches expected format
  assert(outputJson.containsKey('id'));
  assert(outputJson.containsKey('name'));
  assert(outputJson.containsKey('description'));
  assert(outputJson.containsKey('quantity'));
  assert(outputJson.containsKey('unitPrice'));
  assert(outputJson.containsKey('weight'));
  assert(!outputJson.containsKey('productId')); // Should not have old productId field
  
  // Test ID generation format
  assert(newItem.id.startsWith('item'));
  print('\n✅ All tests passed! The OrderItem structure matches the expected JSON format.');
}
