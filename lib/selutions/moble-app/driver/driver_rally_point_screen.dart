import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/data/sample_data.dart';
import 'orders_list_screen.dart';

class DriverRallyPointScreen extends StatefulWidget {
  final Users driver;

  const DriverRallyPointScreen({super.key, required this.driver});

  @override
  State<DriverRallyPointScreen> createState() => _DriverRallyPointScreenState();
}

class _DriverRallyPointScreenState extends State<DriverRallyPointScreen> {
  Driver? driverLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  void _loadDriverData() {
    driverLocation = SampleDataProvider.getDrivers()
        .firstWhere((driver) => driver.id  == widget.driver.UId, orElse: () =>
        Driver(
          id : widget.driver.UId,
          currentLocation: Location(latitude: 31.2001, longitude: 29.9187),
          status: DriverStatus.available,
          lastLocationUpdate: DateTime.now(),
          rating: 4.5,
        ));
  }

  Future<void> _saveRallyPoint(double latitude, double longitude) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // محاكاة حفظ نقطة التجمع
      await Future.delayed(const Duration(seconds: 1));

      final newLocation = Location(latitude: latitude, longitude: longitude);
      
      if (driverLocation != null) {
        final updatedDriver = Driver(
          id : driverLocation!.id ,
          currentLocation: driverLocation!.currentLocation,
          status: driverLocation!.status,
          rallyPoint: newLocation,
          lastLocationUpdate: DateTime.now(),
          rating: driverLocation!.rating,
        );
        
        // تحديث البيانات - محاكاة فقط
        setState(() {
          driverLocation = updatedDriver;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ نقطة التجمع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDriverStatus() async {
    if (driverLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final newStatus = driverLocation!.status == DriverStatus.available
          ? DriverStatus.at_rally_point
          : DriverStatus.available;

      final updatedDriver = Driver(
        id: driverLocation!.id ,
        currentLocation: driverLocation!.currentLocation,
        status: newStatus,
        rallyPoint: driverLocation!.rallyPoint,
        lastLocationUpdate: DateTime.now(),
        rating: driverLocation!.rating,
      );

      // تحديث البيانات - محاكاة فقط
      setState(() {
        driverLocation = updatedDriver;
      });

      final statusText = newStatus == DriverStatus.available ? 'متاح' : 'في نقطة التجمع';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تغيير الحالة إلى: $statusText'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrdersListScreen(driver: widget.driver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تحديد نقطة التجمع'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: _navigateToOrders,
            tooltip: 'عرض الطلبات',
          ),
        ],
      ),
      body: driverLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // معلومات السائق
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green[600],
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.driver.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.driver.phone,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getDriverStatusDisplayName(driverLocation!.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600], size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'التقييم: ${driverLocation!.rating}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // معلومات الموقع الحالي
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'الموقع الحالي',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'خط العرض: ${driverLocation!.currentLocation!.latitude.toStringAsFixed(6)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            'خط الطول: ${driverLocation!.currentLocation!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // نقطة التجمع
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flag, color: Colors.orange[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'نقطة التجمع',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (driverLocation!.rallyPoint != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'خط العرض: ${driverLocation!.rallyPoint!.latitude.toStringAsFixed(6)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Text(
                                  'خط الطول: ${driverLocation!.rallyPoint!.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            )
                          else
                            Text(
                              'لم يتم تحديد نقطة تجمع بعد',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // محاكاة الخريطة
                  Expanded(
                    child: Card(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[100]!,
                              Colors.green[100]!,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'محاكاة الخريطة',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اضغط على "حفظ نقطة التجمع" لتحديد موقعك المفضل',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Google Maps API Key: AIzaSyD2duRi55YWuhTmCqH8gFEV7gGDhoYsJUQ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontFamily: 'monospace',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // أزرار التحكم
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _saveRallyPoint(
                                    driverLocation!.currentLocation!.latitude + 0.001,
                                    driverLocation!.currentLocation!.longitude + 0.001,
                                  ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: const Text('حفظ نقطة التجمع'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _toggleDriverStatus,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(_getStatusIcon()),
                          label: Text(_getStatusButtonText()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getStatusColor(),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  String _getDriverStatusDisplayName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  Color _getStatusColor() {
    switch (driverLocation!.status) {
      case DriverStatus.available:
        return Colors.green[600]!;
      case DriverStatus.busy:
        return Colors.orange[600]!;
      case DriverStatus.at_rally_point:
        return Colors.blue[600]!;
    }
  }

  IconData _getStatusIcon() {
    switch (driverLocation!.status) {
      case DriverStatus.available:
        return Icons.pause;
      case DriverStatus.busy:
        return Icons.play_arrow;
      case DriverStatus.at_rally_point:
        return Icons.play_arrow;
    }
  }

  String _getStatusButtonText() {
    switch (driverLocation!.status) {
      case DriverStatus.available:
        return 'تغيير للراحة';
      case DriverStatus.busy:
        return 'تغيير لمتاح';
      case DriverStatus.at_rally_point:
        return 'تغيير لمتاح';
    }
  }
}
