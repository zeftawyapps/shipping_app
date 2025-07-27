import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class DriverDetailsDialog extends StatelessWidget {
  final Driver driver;
  final Users user;
  final AppStateManager appState;

  const DriverDetailsDialog({
    Key? key,
    required this.driver,
    required this.user,
    required this.appState,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    Driver driver,
    Users user,
    AppStateManager appState,
  ) {
    return showDialog(
      context: context,
      builder: (context) => DriverDetailsDialog(
        driver: driver,
        user: user,
        appState: appState,
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
            width: 120,
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

  String _getStatusDisplayName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final driverOrders = appState.orders.where((o) => o.driverId == driver.id).toList();
    final completedOrders = driverOrders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders = driverOrders.where((o) => o.status == OrderStatus.cancelled).length;

    return AlertDialog(
      title: Text('تفاصيل السائق: ${user.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('الاسم', user.name),
            _buildDetailRow('البريد الإلكتروني', user.email),
            _buildDetailRow('رقم الهاتف', user.phone),
            _buildDetailRow(
              'الحالة',
              _getStatusDisplayName(driver.status),
            ),
            _buildDetailRow(
              'التقييم',
              '${driver.rating.toStringAsFixed(1)}/5.0',
            ),
            _buildDetailRow(
              'الموقع الحالي',
              '${driver.currentLocation.latitude.toStringAsFixed(4)}, ${driver.currentLocation.longitude.toStringAsFixed(4)}',
            ),
            _buildDetailRow(
              'آخر تحديث للموقع',
              _formatDate(driver.lastLocationUpdate),
            ),
            const Divider(),
            _buildDetailRow(
              'إجمالي الطلبات',
              driverOrders.length.toString(),
            ),
            _buildDetailRow(
              'الطلبات المكتملة',
              completedOrders.toString(),
            ),
            _buildDetailRow(
              'الطلبات الملغاة',
              cancelledOrders.toString(),
            ),
            _buildDetailRow(
              'معدل الإنجاز',
              driverOrders.isNotEmpty
                  ? '${((completedOrders / driverOrders.length) * 100).toStringAsFixed(1)}%'
                  : '0%',
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
    );
  }
}
