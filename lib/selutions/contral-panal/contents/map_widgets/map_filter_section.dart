import 'package:flutter/material.dart';
import '../../../../logic/models/location_point.dart';

class MapFilterSection extends StatelessWidget {
  final bool showDrivers;
  final bool showShops;
  final bool showOrders;
  final LocationType? selectedFilter;
  final VoidCallback onRefresh;
  final ValueChanged<bool> onShowDriversChanged;
  final ValueChanged<bool> onShowShopsChanged;
  final ValueChanged<bool> onShowOrdersChanged;
  final ValueChanged<LocationType?> onFilterChanged;

  const MapFilterSection({
    super.key,
    required this.showDrivers,
    required this.showShops,
    required this.showOrders,
    required this.selectedFilter,
    required this.onRefresh,
    required this.onShowDriversChanged,
    required this.onShowShopsChanged,
    required this.onShowOrdersChanged,
    required this.onFilterChanged,
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
              'فلاتر الخريطة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                // Show/Hide toggles
                FilterChip(
                  label: const Text('السائقين'),
                  selected: showDrivers,
                  onSelected: onShowDriversChanged,
                  avatar: Icon(
                    Icons.drive_eta,
                    color: showDrivers ? Colors.white : Colors.blue,
                    size: 18,
                  ),
                ),
                FilterChip(
                  label: const Text('المحلات'),
                  selected: showShops,
                  onSelected: onShowShopsChanged,
                  avatar: Icon(
                    Icons.store,
                    color: showShops ? Colors.white : Colors.green,
                    size: 18,
                  ),
                ),
                FilterChip(
                  label: const Text('الطلبات'),
                  selected: showOrders,
                  onSelected: onShowOrdersChanged,
                  avatar: Icon(
                    Icons.local_shipping,
                    color: showOrders ? Colors.white : Colors.orange,
                    size: 18,
                  ),
                ),
                
                // Specific type filter
                DropdownButton<LocationType?>(
                  value: selectedFilter,
                  hint: const Text('نوع محدد'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('جميع الأنواع'),
                    ),
                    ...LocationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getLocationTypeDisplayName(type)),
                      );
                    }).toList(),
                  ],
                  onChanged: onFilterChanged,
                ),
                
                // Refresh button
                ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
