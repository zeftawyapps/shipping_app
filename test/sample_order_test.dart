import 'package:shipping_app/logic/data/sample_data.dart';
import 'dart:convert';

void main() {
  final firstOrder = sampleOrders.first;
  print('Sample Order JSON:');
  final orderJson = firstOrder.toJson();
  print(JsonEncoder.withIndent('  ').convert(orderJson));
  
  print('\nOrder Items:');
  for (final item in firstOrder.items) {
    print('- ID: ${item.id}');
    print('  Name: ${item.name}');
    print('  Description: ${item.description}');
    print('  Weight: ${item.weight}');
    print('');
  }
}
