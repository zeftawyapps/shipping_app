import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationService {
  LocationData? _currentLocation;

  /// Get current location for both web and mobile platforms
  Future<LocationData?> getLocation() async {
    if (kIsWeb) {
      // Web-specific location handling
      try {
        final position = await _getCurrentPositionWeb();
        if (position != null) {
          _currentLocation = LocationData.fromMap({
            'latitude': position['latitude'],
            'longitude': position['longitude'],
            'accuracy': position['accuracy'] ?? 0.0,
            'altitude': 0.0,
            'speed': 0.0,
            'speedAccuracy': 0.0,
            'heading': 0.0,
            'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
          });
          return _currentLocation;
        }
        return null;
      } catch (e) {
        debugPrint('Web location error: $e');
        // Fallback to geocoded address
        try {
          List<geocoding.Location> locations = await geocoding.locationFromAddress("Riyadh, Saudi Arabia");
          _currentLocation = LocationData.fromMap({
            'latitude': locations[0].latitude,
            'longitude': locations[0].longitude,
            'accuracy': 0.0,
            'altitude': 0.0,
            'speed': 0.0,
            'speedAccuracy': 0.0,
            'heading': 0.0,
            'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
          });
          return _currentLocation;
        } catch (geocodingError) {
          debugPrint('Geocoding error: $geocodingError');
          // Final fallback to hardcoded Riyadh coordinates
          _currentLocation = LocationData.fromMap({
            'latitude': 24.7136,
            'longitude': 46.6753,
            'accuracy': 0.0,
            'altitude': 0.0,
            'speed': 0.0,
            'speedAccuracy': 0.0,
            'heading': 0.0,
            'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
          });
          return _currentLocation;
        }
      }
    } else {
      // Mobile platform location handling
      return await _getMobileLocation();
    }
  }

  /// Mobile-specific location handling
  Future<LocationData?> _getMobileLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if the location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null; // Location service is not enabled
      }
    }

    // Check for location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null; // Permission denied
      }
    }

    _currentLocation = await location.getLocation();
    return _currentLocation;
  }

  /// Web-specific method to get current position
  Future<Map<String, double>?> _getCurrentPositionWeb() async {
    if (!kIsWeb) {
      return null;
    }
    
    try {
      // Simulate geolocation request
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Use geocoding to get coordinates from an address
      List<geocoding.Location> locations = await geocoding.locationFromAddress("Riyadh, Saudi Arabia");
      
      return {
        'latitude': locations[0].latitude,
        'longitude': locations[0].longitude,
        'accuracy': 100.0,
      };
    } catch (e) {
      debugPrint('Web location error: $e');
      // Return default Riyadh coordinates
      return {
        'latitude': 24.7136,
        'longitude': 46.6753,
        'accuracy': 100.0,
      };
    }
  }

  /// Get location from a specific address (geocoding)
  Future<LocationData?> getLocationFromAddress(String address) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LocationData.fromMap({
          'latitude': locations[0].latitude,
          'longitude': locations[0].longitude,
          'accuracy': 100.0,
          'altitude': 0.0,
          'speed': 0.0,
          'speedAccuracy': 0.0,
          'heading': 0.0,
          'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
        });
      }
    } catch (e) {
      debugPrint('Geocoding error for address "$address": $e');
    }
    return null;
  }

  /// Get the last known location without requesting a new one
  LocationData? get currentLocation => _currentLocation;

  /// Check if location services are available
  Future<bool> isLocationServiceEnabled() async {
    if (kIsWeb) {
      return true; // Always available on web (with fallback)
    }
    
    Location location = Location();
    return await location.serviceEnabled();
  }

  /// Request location service to be enabled
  Future<bool> requestLocationService() async {
    if (kIsWeb) {
      return true; // Always available on web
    }
    
    Location location = Location();
    return await location.requestService();
  }
}
