import 'package:flutter/material.dart';
import '../../../../logic/models/location_point.dart';

class MapStatisticsSection extends StatelessWidget {
  final List<LocationPoint> allLocationPoints;
  final List<LocationPoint> filteredLocationPoints;

  const MapStatisticsSection({
    super.key,
    required this.allLocationPoints,
    required this.filteredLocationPoints,
  });

  @override
  Widget build(BuildContext context) {
    final driverCount = allLocationPoints.where((p) => p.type == LocationType.driver).length;
    final shopCount = allLocationPoints.where((p) => p.type == LocationType.shop).length;
    final orderCount = allLocationPoints.where((p) => p.type == LocationType.order_pickup || p.type == LocationType.order_delivery).length;

    return Row(
      children: [
        Expanded(
          child: _MapStatCard(
            title: 'السائقين',
            value: driverCount.toString(),
            icon: Icons.drive_eta,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MapStatCard(
            title: 'المحلات',
            value: shopCount.toString(),
            icon: Icons.store,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MapStatCard(
            title: 'الطلبات',
            value: (orderCount ~/ 2).toString(), // Divide by 2 since each order has pickup and delivery
            icon: Icons.local_shipping,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MapStatCard(
            title: 'المعروض',
            value: filteredLocationPoints.length.toString(),
            icon: Icons.visibility,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}

class _MapStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MapStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
