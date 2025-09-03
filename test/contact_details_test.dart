// Test example to verify the new JSON structure
import 'dart:convert';
import 'package:shipping_app/logic/models/contact_details.dart';

void main() {
  // Test JSON from backend format
  final backendJson = {
    "name": "John Customer",
    "phone": "+20987654321",
    "address": "456 Customer Ave, Tanta, Egypt",
    "latitude": 30.7900,
    "longitude": 31.0050,
    "notes": "Leave at front door"
  };

  // Test fromJson
  final contactDetails = ContactDetails.fromJson(backendJson);
  print('Parsed from JSON:');
  print('Name: ${contactDetails.name}');
  print('Phone: ${contactDetails.phone}');
  print('Address: ${contactDetails.address}');
  print('Latitude: ${contactDetails.latitude}');
  print('Longitude: ${contactDetails.longitude}');
  print('Notes: ${contactDetails.notes}');
  print('Location (backward compatibility): ${contactDetails.location.latitude}, ${contactDetails.location.longitude}');

  // Test toJson
  final outputJson = contactDetails.toJson();
  print('\nSerialized to JSON:');
  print(JsonEncoder.withIndent('  ').convert(outputJson));

  // Verify the structure matches backend expectations
  assert(outputJson.containsKey('latitude'));
  assert(outputJson.containsKey('longitude'));
  assert(outputJson.containsKey('notes'));
  assert(!outputJson.containsKey('location')); // Should not have nested location
  
  print('\n✅ All tests passed! The structure matches backend expectations.');
}
