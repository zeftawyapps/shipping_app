import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../logic/models/location_point.dart';
import '../../../../widgets/map_location.dart' as map_widget;

class MapSection extends StatelessWidget {
  final List<LocationPoint> filteredLocationPoints;
  final ValueChanged<LatLng> onLocationSelected;

  const MapSection({
    super.key,
    required this.filteredLocationPoints,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: map_widget.MapLocation(
          initialPoints: _convertToMapLocationPoints(filteredLocationPoints),
          onLocationSelected: onLocationSelected,
          showLocationPicker: false, // Don't show picker buttons in this context
        ),
      ),
    );
  }

  List<map_widget.LocationPoint> _convertToMapLocationPoints(List<LocationPoint> points) {
    return points.map((point) {
      // Convert LocationType to map_widget.LocationPointType
      map_widget.LocationPointType mapType;
      switch (point.type) {
        case LocationType.driver:
          mapType = map_widget.LocationPointType.driver;
          break;
        case LocationType.shop:
          mapType = map_widget.LocationPointType.shop;
          break;
        case LocationType.order_pickup:
        case LocationType.order_delivery:
          mapType = map_widget.LocationPointType.order;
          break;
      }

      return map_widget.LocationPoint(
        id: point.id ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
        position: LatLng(
          point.location.latitude,
          point.location.longitude,
        ),
        title: point.name,
        type: mapType,
        description: point.statusText,
      );
    }).toList();
  }
}
