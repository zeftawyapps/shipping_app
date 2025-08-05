import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shipping_app/logic/models/models.dart';
import 'package:shipping_app/logic/models/location_point.dart';
import 'package:shipping_app/widgets/map_location.dart' as map_widget;

import '../../../logic/data/sample_data.dart';

class MapContentScreen extends StatefulWidget {
  const MapContentScreen({Key? key}) : super(key: key);

  @override
  State<MapContentScreen> createState() => _MapContentScreenState();
}

class _MapContentScreenState extends State<MapContentScreen> {
  // Filter states
  bool _showDrivers = true;
  bool _showShops = true;
  bool _showOrders = true;
  LocationType? _selectedFilter;
  
  // Map state
  List<LocationPoint> _allLocationPoints = [];
  List<LocationPoint> _filteredLocationPoints = [];

  @override
  void initState() {
    super.initState();
    _loadLocationPoints();
  }

  void _loadLocationPoints() {
    final List<LocationPoint> points = [];

    // Load drivers
    final drivers = SampleDataProvider.getDrivers();
    for (final driver in drivers) {
      if (driver.currentLocation != null) {
        points.add(LocationPoint.fromDriver(
          driverId: driver.id!,
          driverName: driver.name ?? 'سائق غير محدد',
          location: driver.currentLocation!,
          phone: driver.phone,
          status: _getDriverStatusName(driver.status),
          rating: driver.rating,
        ));
      }
    }

    // Load shops
    final shops = SampleDataProvider.getShops();
    for (final shop in shops) {
      if (shop.location != null) {
        points.add(LocationPoint.fromShop(
          shopId: shop.shopId,
          shopName: shop.userName,
          location: shop.location!,
          address: shop.address,
          phone: shop.phone,
          isActive: shop.isActive,
        ));
      }
    }

    // Load orders (pickup and delivery points)
    final orders = SampleDataProvider.getOrders();
    for (final order in orders) {
      // Add pickup point (shop location)
      final shop = SampleDataProvider.getShopById(order.shopId);
      if (shop?.location != null) {
        points.add(LocationPoint.fromOrderPickup(
          orderId: order.shopId,
          shopName: shop!.userName,
          location: shop.location!,
          customerName: order.recipientDetails.name,
          orderStatus: _getOrderStatusName(order.status),
          totalPrice: order.totalOrderPrice,
        ));
      }

      // Add delivery point (recipient location)
      points.add(LocationPoint.fromOrderDelivery(
        orderId: order.shopId,
        customerName: order.recipientDetails.name,
        location: order.recipientDetails.location,
        address: order.recipientDetails.address,
        phone: order.recipientDetails.phone,
        orderStatus: _getOrderStatusName(order.status),
        totalPrice: order.totalOrderPrice,
      ));
    }

    setState(() {
      _allLocationPoints = points;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<LocationPoint> filtered = _allLocationPoints.where((point) {
      bool typeFilter = true;
      
      if (!_showDrivers && point.type == LocationType.driver) typeFilter = false;
      if (!_showShops && point.type == LocationType.shop) typeFilter = false;
      if (!_showOrders && (point.type == LocationType.order_pickup || point.type == LocationType.order_delivery)) typeFilter = false;
      
      if (_selectedFilter != null && point.type != _selectedFilter) typeFilter = false;
      
      return typeFilter && point.isActive;
    }).toList();

    setState(() {
      _filteredLocationPoints = filtered;
    });
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'خريطة التوصيل',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Filters
          _buildFilterSection(),
          const SizedBox(height: 16),

          // Statistics
          _buildStatisticsSection(),
          const SizedBox(height: 16),

          // Map and Legend
          Expanded(
            child: Row(
              children: [
                // Map Area
                Expanded(
                  flex: 3,
                  child: _buildMapSection(),
                ),
                const SizedBox(width: 16),
                
                // Legend and Details
                Expanded(
                  flex: 1,
                  child: _buildLegendSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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
                  selected: _showDrivers,
                  onSelected: (value) {
                    setState(() {
                      _showDrivers = value;
                      _applyFilters();
                    });
                  },
                  avatar: Icon(
                    Icons.drive_eta,
                    color: _showDrivers ? Colors.white : Colors.blue,
                    size: 18,
                  ),
                ),
                FilterChip(
                  label: const Text('المحلات'),
                  selected: _showShops,
                  onSelected: (value) {
                    setState(() {
                      _showShops = value;
                      _applyFilters();
                    });
                  },
                  avatar: Icon(
                    Icons.store,
                    color: _showShops ? Colors.white : Colors.green,
                    size: 18,
                  ),
                ),
                FilterChip(
                  label: const Text('الطلبات'),
                  selected: _showOrders,
                  onSelected: (value) {
                    setState(() {
                      _showOrders = value;
                      _applyFilters();
                    });
                  },
                  avatar: Icon(
                    Icons.local_shipping,
                    color: _showOrders ? Colors.white : Colors.orange,
                    size: 18,
                  ),
                ),
                
                // Specific type filter
                DropdownButton<LocationType?>(
                  value: _selectedFilter,
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
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value;
                      _applyFilters();
                    });
                  },
                ),
                
                // Refresh button
                ElevatedButton.icon(
                  onPressed: _loadLocationPoints,
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

  Widget _buildStatisticsSection() {
    final driverCount = _allLocationPoints.where((p) => p.type == LocationType.driver).length;
    final shopCount = _allLocationPoints.where((p) => p.type == LocationType.shop).length;
    final orderCount = _allLocationPoints.where((p) => p.type == LocationType.order_pickup || p.type == LocationType.order_delivery).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'السائقين',
            value: driverCount.toString(),
            icon: Icons.drive_eta,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'المحلات',
            value: shopCount.toString(),
            icon: Icons.store,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'الطلبات',
            value: (orderCount ~/ 2).toString(), // Divide by 2 since each order has pickup and delivery
            icon: Icons.local_shipping,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            title: 'المعروض',
            value: _filteredLocationPoints.length.toString(),
            icon: Icons.visibility,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildMapSection() {
    return Card(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: map_widget.MapLocation(
          initialPoints: _convertToMapLocationPoints(_filteredLocationPoints),
          onLocationSelected: (position) {
            // Handle location selection
            _onMapTap(Offset(position.latitude, position.longitude));
          },
          showLocationPicker: false, // Don't show picker buttons in this context
        ),
      ),
    );
  }

  Widget _buildLegendSection() {
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
                itemCount: _filteredLocationPoints.length,
                itemBuilder: (context, index) {
                  final point = _filteredLocationPoints[index];
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
                    onTap: () => _showLocationDetails(point),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDetails(LocationPoint point) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getLocationTypeColor(point.type),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getLocationTypeIcon(point.type),
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(point.name)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('النوع', point.typeDisplayName),
              _buildDetailRow('الحالة', point.statusText),
              if (point.description != null)
                _buildDetailRow('الوصف', point.description!),
              _buildDetailRow(
                'الموقع',
                '${point.location.latitude.toStringAsFixed(6)}, ${point.location.longitude.toStringAsFixed(6)}',
              ),
              if (point.phoneNumber != null)
                _buildDetailRow('الهاتف', point.phoneNumber!),
              if (point.rating != null)
                _buildDetailRow('التقييم', '${point.rating!.toStringAsFixed(1)} / 5.0'),
              if (point.totalPrice != null)
                _buildDetailRow('السعر', '${point.totalPrice!.toStringAsFixed(2)} ج.م'),
              _buildDetailRow(
                'آخر تحديث',
                _formatDateTime(point.lastUpdated),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _onMapTap(Offset position) {
    // Handle map tap - could be used for adding new points or other interactions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم النقر على الخريطة في الموضع: ${position.dx.toInt()}, ${position.dy.toInt()}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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

  String _getDriverStatusName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  String _getOrderStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return 'في انتظار القبول';
      case OrderStatus.accepted:
        return 'تم القبول';
      case OrderStatus.picked_up:
        return 'تم الاستلام';
      case OrderStatus.on_the_way:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغى';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
