import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shipping_app/services/location_service.dart';
import 'package:shipping_app/widgets/location_picker_dialog.dart';

enum LocationPointType { driver, shop, order }

class LocationPoint {
  final String id;
  final LatLng position;
  final String title;
  final LocationPointType type;
  final String? description;

  LocationPoint({
    required this.id,
    required this.position,
    required this.title,
    required this.type,
    this.description,
  });
}

class MapLocation extends StatefulWidget {
  final List<LocationPoint>? initialPoints;
  final Function(LatLng)? onLocationSelected;
  final bool showLocationPicker;

  const MapLocation({
    super.key,
    this.initialPoints,
    this.onLocationSelected,
    this.showLocationPicker = true,
  });

  @override
  State<MapLocation> createState() => MapLocationState();
}

class MapLocationState extends State<MapLocation> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final LocationService _locationService = LocationService();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(24.7136, 46.6753), // Riyadh, Saudi Arabia
    zoom: 12.0,
  );
  
  LocationData? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = false;
  List<LocationPoint> _locationPoints = [];

  @override
  void initState() {
    super.initState();
    _initializeLocationPoints();
  }

  void _initializeLocationPoints() {
    // Initialize with provided points or default points
    _locationPoints = widget.initialPoints ?? _getDefaultLocationPoints();
    _updateMarkersFromPoints();
  }

  List<LocationPoint> _getDefaultLocationPoints() {
    return [
      LocationPoint(
        id: 'driver_1',
        position: const LatLng(24.7136, 46.6753),
        title: 'سائق 1',
        type: LocationPointType.driver,
        description: 'سائق متاح',
      ),
      LocationPoint(
        id: 'shop_1',
        position: const LatLng(24.7200, 46.6800),
        title: 'متجر 1',
        type: LocationPointType.shop,
        description: 'متجر مفتوح',
      ),
      LocationPoint(
        id: 'order_1',
        position: const LatLng(24.7100, 46.6700),
        title: 'طلب 1',
        type: LocationPointType.order,
        description: 'طلب في الانتظار',
      ),
    ];
  }

  Future<void> _updateMarkersFromPoints() async {
    final Set<Marker> newMarkers = {};
    
    for (final point in _locationPoints) {
      final icon = await _getSimpleMarkerIcon(point.type);
      newMarkers.add(
        Marker(
          markerId: MarkerId(point.id),
          position: point.position,
          infoWindow: InfoWindow(
            title: point.title,
            snippet: point.description ?? 
              '${point.position.latitude.toStringAsFixed(6)}, ${point.position.longitude.toStringAsFixed(6)}',
          ),
          icon: icon,
        ),
      );
    }
    
    setState(() {
      _markers = newMarkers;
    });
  }

  // Create custom shaped markers using Canvas path drawing
  Future<BitmapDescriptor> _createSimpleMarker({
    required Color color,
    required double size,
    required LocationPointType type,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Main shape paint
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // White border paint
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Background circle for all shapes
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, paint);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, strokePaint);
    
    // Draw specific shapes based on type
    final shapePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shapeStrokePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    switch (type) {
      case LocationPointType.driver:
        _drawMotorcycle(canvas, size, shapePaint, shapeStrokePaint);
        break;
      case LocationPointType.shop:
        _drawShop(canvas, size, shapePaint, shapeStrokePaint);
        break;
      case LocationPointType.order:
        _drawDeliveryBox(canvas, size, shapePaint, shapeStrokePaint);
        break;
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // Draw motorcycle shape for drivers
  void _drawMotorcycle(Canvas canvas, double size, Paint fillPaint, Paint strokePaint) {
    final center = Offset(size / 2, size / 2);
    final scale = size / 40.0; // Scale factor
    
    // Motorcycle body path
    final path = Path();
    
    // Main body (simplified motorcycle silhouette)
    path.moveTo(center.dx - 8 * scale, center.dy);
    path.lineTo(center.dx - 6 * scale, center.dy - 4 * scale);
    path.lineTo(center.dx + 2 * scale, center.dy - 4 * scale);
    path.lineTo(center.dx + 8 * scale, center.dy - 2 * scale);
    path.lineTo(center.dx + 8 * scale, center.dy + 2 * scale);
    path.lineTo(center.dx - 8 * scale, center.dy + 2 * scale);
    path.close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    
    // Wheels
    canvas.drawCircle(Offset(center.dx - 5 * scale, center.dy + 3 * scale), 2 * scale, fillPaint);
    canvas.drawCircle(Offset(center.dx + 5 * scale, center.dy + 3 * scale), 2 * scale, fillPaint);
    canvas.drawCircle(Offset(center.dx - 5 * scale, center.dy + 3 * scale), 2 * scale, strokePaint);
    canvas.drawCircle(Offset(center.dx + 5 * scale, center.dy + 3 * scale), 2 * scale, strokePaint);
  }

  // Draw shop shape for shops
  void _drawShop(Canvas canvas, double size, Paint fillPaint, Paint strokePaint) {
    final center = Offset(size / 2, size / 2);
    final scale = size / 40.0; // Scale factor
    
    // Shop building path
    final path = Path();
    
    // Building base
    path.moveTo(center.dx - 8 * scale, center.dy + 6 * scale);
    path.lineTo(center.dx - 8 * scale, center.dy - 2 * scale);
    path.lineTo(center.dx + 8 * scale, center.dy - 2 * scale);
    path.lineTo(center.dx + 8 * scale, center.dy + 6 * scale);
    path.close();
    
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
    
    // Roof (triangle)
    final roofPath = Path();
    roofPath.moveTo(center.dx - 10 * scale, center.dy - 2 * scale);
    roofPath.lineTo(center.dx, center.dy - 8 * scale);
    roofPath.lineTo(center.dx + 10 * scale, center.dy - 2 * scale);
    roofPath.close();
    
    canvas.drawPath(roofPath, fillPaint);
    canvas.drawPath(roofPath, strokePaint);
    
    // Door
    final doorRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 2 * scale),
      width: 3 * scale,
      height: 6 * scale,
    );
    canvas.drawRect(doorRect, strokePaint);
  }

  // Draw delivery box shape for orders
  void _drawDeliveryBox(Canvas canvas, double size, Paint fillPaint, Paint strokePaint) {
    final center = Offset(size / 2, size / 2);
    final scale = size / 40.0; // Scale factor
    
    // Main box
    final boxRect = Rect.fromCenter(
      center: center,
      width: 12 * scale,
      height: 8 * scale,
    );
    canvas.drawRect(boxRect, fillPaint);
    canvas.drawRect(boxRect, strokePaint);
    
    // Box tape/lines
    final tapePaint = Paint()
      ..color = strokePaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Horizontal tape
    canvas.drawLine(
      Offset(center.dx - 6 * scale, center.dy),
      Offset(center.dx + 6 * scale, center.dy),
      tapePaint,
    );
    
    // Vertical tape
    canvas.drawLine(
      Offset(center.dx, center.dy - 4 * scale),
      Offset(center.dx, center.dy + 4 * scale),
      tapePaint,
    );
    
    // Small handle or label
    final handleRect = Rect.fromCenter(
      center: Offset(center.dx + 4 * scale, center.dy - 2 * scale),
      width: 2 * scale,
      height: 1 * scale,
    );
    canvas.drawRect(handleRect, strokePaint);
  }

  Future<BitmapDescriptor> _getSimpleMarkerIcon(LocationPointType type) async {
    switch (type) {
      case LocationPointType.driver:
        return await _createSimpleMarker(
          color: const Color(0xFF2196F3), // Blue
          size: 40.0,
          type: type,
        );
      case LocationPointType.shop:
        return await _createSimpleMarker(
          color: const Color(0xFF4CAF50), // Green
          size: 40.0,
          type: type,
        );
      case LocationPointType.order:
        return await _createSimpleMarker(
          color: const Color(0xFFFF9800), // Orange
          size: 40.0,
          type: type,
        );
    }
  }

  void addLocationPoint(LocationPoint point) {
    _locationPoints.add(point);
    _updateMarkersFromPoints();
  }

  void removeLocationPoint(String pointId) {
    _locationPoints.removeWhere((point) => point.id == pointId);
    _updateMarkersFromPoints();
  }

  void updateLocationPoint(LocationPoint updatedPoint) {
    final index = _locationPoints.indexWhere((point) => point.id == updatedPoint.id);
    if (index != -1) {
      _locationPoints[index] = updatedPoint;
      _updateMarkersFromPoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onTap: _onMapTap,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                ),
                
                // GPS Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    backgroundColor: Colors.blue,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
                
                // Location Types Filter (if needed)
                if (widget.showLocationPicker)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      children: [
                        _buildFilterButton('السائقين', LocationPointType.driver, Colors.blue),
                        const SizedBox(height: 8),
                        _buildFilterButton('المتاجر', LocationPointType.shop, Colors.green),
                        const SizedBox(height: 8),
                        _buildFilterButton('الطلبات', LocationPointType.order, Colors.orange),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.showLocationPicker ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Location Picker Dialog Button
          FloatingActionButton(
            heroTag: "location_picker",
            onPressed: _openLocationPicker,
            backgroundColor: Colors.green,
            child: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 16),
          // Add Location Button
          FloatingActionButton.extended(
            heroTag: "add_location",
            onPressed: _addNewLocation,
            label: const Text('إضافة موقع'),
            icon: const Icon(Icons.add_location),
          ),
        ],
      ) : null,
    );
  }

  Widget _buildFilterButton(String label, LocationPointType type, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _toggleLocationTypeVisibility(type),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onMapTap(LatLng position) {
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(position);
    }
    
    // Show information about the tapped location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'موقع محدد: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentLocation = await _locationService.getLocation();
      
      if (_currentLocation != null) {
        LatLng currentPosition = LatLng(
          _currentLocation!.latitude ?? 24.7136,   // Default to Riyadh if null
          _currentLocation!.longitude ?? 46.6753,  // Default to Riyadh if null
        );
        
        // Add marker for current location
        _addCurrentLocationMarker(currentPosition);
        
        // Move camera to current location
        final cameraPosition = CameraPosition(
          target: currentPosition,
          zoom: 15.0, // Better zoom level for city view
        );

        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديد موقعك الحالي'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _handleLocationError();
      }
    } catch (e) {
      _handleLocationError();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addCurrentLocationMarker(LatLng position) {
    final currentLocationPoint = LocationPoint(
      id: 'current_location',
      position: position,
      title: 'موقعي الحالي',
      type: LocationPointType.driver, // Or create a new type for current location
      description: 'الموقع الحالي للمستخدم',
    );
    
    // Remove existing current location marker if any
    _locationPoints.removeWhere((point) => point.id == 'current_location');
    
    // Add new current location marker
    addLocationPoint(currentLocationPoint);
  }

  void _handleLocationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن الحصول على الموقع الحالي. سيتم استخدام الموقع الافتراضي.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    // Use default location (Riyadh, Saudi Arabia)
    const defaultPosition = LatLng(24.7136, 46.6753);
    _addCurrentLocationMarker(defaultPosition);
    
    // Move to default location
    _moveToLocation(defaultPosition, 15.0);
  }

  Future<void> _moveToLocation(LatLng position, double zoom) async {
    final cameraPosition = CameraPosition(
      target: position,
      zoom: zoom,
    );

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _toggleLocationTypeVisibility(LocationPointType type) {
    setState(() {
      // Toggle visibility logic can be implemented here
      // For now, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تبديل عرض: ${_getTypeLabel(type)}'),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  String _getTypeLabel(LocationPointType type) {
    switch (type) {
      case LocationPointType.driver:
        return 'السائقين';
      case LocationPointType.shop:
        return 'المتاجر';
      case LocationPointType.order:
        return 'الطلبات';
    }
  }

  Future<void> _addNewLocation() async {
    // Get current map center as initial position
    final GoogleMapController controller = await _controller.future;
    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    final LatLng center = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );

    final LatLng? selectedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialPosition: center,
        title: 'إضافة موقع جديد',
      ),
    );

    if (selectedLocation != null) {
      // Show dialog to select location type
      final LocationPointType? selectedType = await _showLocationTypeDialog();
      
      if (selectedType != null) {
        final newPoint = LocationPoint(
          id: 'new_${DateTime.now().millisecondsSinceEpoch}',
          position: selectedLocation,
          title: 'موقع جديد',
          type: selectedType,
          description: 'موقع مضاف يدوياً',
        );
        
        addLocationPoint(newPoint);
        
        // Move map to new location
        await _moveToLocation(selectedLocation, 15.0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إضافة موقع جديد: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<LocationPointType?> _showLocationTypeDialog() async {
    return showDialog<LocationPointType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر نوع الموقع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_eta, color: Colors.blue),
              title: const Text('سائق'),
              onTap: () => Navigator.of(context).pop(LocationPointType.driver),
            ),
            ListTile(
              leading: const Icon(Icons.store, color: Colors.green),
              title: const Text('متجر'),
              onTap: () => Navigator.of(context).pop(LocationPointType.shop),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.orange),
              title: const Text('طلب'),
              onTap: () => Navigator.of(context).pop(LocationPointType.order),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    // Get current map center as initial position
    final GoogleMapController controller = await _controller.future;
    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    final LatLng center = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );

    final LatLng? selectedLocation = await showDialog<LatLng>(
      context: context,
      builder: (context) => LocationPickerDialog(
        initialPosition: center,
        title: 'Pick Location',
      ),
    );

    if (selectedLocation != null) {
      // Add marker for selected location
      final selectedPoint = LocationPoint(
        id: 'selected_location',
        position: selectedLocation,
        title: 'موقع محدد',
        type: LocationPointType.order,
        description: 'موقع تم اختياره من الخريطة',
      );
      
      // Remove existing selected location marker if any
      _locationPoints.removeWhere((point) => point.id == 'selected_location');
      addLocationPoint(selectedPoint);
      
      // Move map to selected location
      await _moveToLocation(selectedLocation, 15.0);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديد الموقع: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
