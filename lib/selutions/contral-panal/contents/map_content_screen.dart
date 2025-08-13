import 'package:flutter/material.dart';
import 'package:shipping_app/logic/models/models.dart';
import 'package:shipping_app/logic/models/location_point.dart';

import '../../../logic/data/sample_data.dart';
import 'map_widgets/map_widgets.dart';

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
          status: MapUtils.getDriverStatusName(driver.status),
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
          orderStatus: MapUtils.getOrderStatusName(order.status),
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
        orderStatus: MapUtils.getOrderStatusName(order.status),
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

  void _onLocationTap(LocationPoint point) {
    LocationDetailsDialog.show(context, point);
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
          MapFilterSection(
            showDrivers: _showDrivers,
            showShops: _showShops,
            showOrders: _showOrders,
            selectedFilter: _selectedFilter,
            onShowDriversChanged: (value) {
              setState(() {
                _showDrivers = value;
                _applyFilters();
              });
            },
            onShowShopsChanged: (value) {
              setState(() {
                _showShops = value;
                _applyFilters();
              });
            },
            onShowOrdersChanged: (value) {
              setState(() {
                _showOrders = value;
                _applyFilters();
              });
            },
            onFilterChanged: (value) {
              setState(() {
                _selectedFilter = value;
                _applyFilters();
              });
            },
            onRefresh: _loadLocationPoints,
          ),
          const SizedBox(height: 16),

          // Statistics
          MapStatisticsSection(
            allLocationPoints: _allLocationPoints,
            filteredLocationPoints: _filteredLocationPoints,
          ),
          const SizedBox(height: 16),

          // Map and Legend
          Expanded(
            child: Row(
              children: [
                // Map Area
                Expanded(
                  flex: 3,
                  child: MapSection(
                    filteredLocationPoints: _filteredLocationPoints,
                    onLocationSelected: (position) {
                      // Handle location selection
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم النقر على الخريطة في الموضع: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Legend and Details
                Expanded(
                  flex: 1,
                  child: MapLegendSection(
                    filteredLocationPoints: _filteredLocationPoints,
                    onLocationSelected: _onLocationTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
