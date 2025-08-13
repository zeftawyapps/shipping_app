import 'package:flutter/material.dart';
import '../../../../logic/models/location_point.dart';

class MapLegendSection extends StatelessWidget {
  final List<LocationPoint> filteredLocationPoints;
  final ValueChanged<LocationPoint> onLocationSelected;

  const MapLegendSection({
    super.key,
    required this.filteredLocationPoints,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مفتاح الخريطة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Legend items
            ...LocationType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getLocationTypeColor(type),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getLocationTypeIcon(type),
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_getLocationTypeDisplayName(type)),
                  ],
                ),
              );
            }).toList(),
            
            const Divider(),
            
            // Location points list
            Expanded(
              child: ListView.builder(
                itemCount: filteredLocationPoints.length,
                itemBuilder: (context, index) {
                  final point = filteredLocationPoints[index];
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getLocationTypeColor(point.type),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getLocationTypeIcon(point.type),
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                    title: Text(
                      point.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      point.statusText,
                      style: const TextStyle(fontSize: 10),
                    ),
                    onTap: () => onLocationSelected(point),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLocationTypeColor(LocationType type) {
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

  IconData _getLocationTypeIcon(LocationType type) {
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

  String _getLocationTypeDisplayName(LocationType type) {
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
}
