import 'package:flutter/material.dart';
import '../../../../logic/models/location_point.dart';

class LocationDetailsDialog extends StatelessWidget {
  final LocationPoint locationPoint;

  const LocationDetailsDialog({
    super.key,
    required this.locationPoint,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getLocationTypeColor(locationPoint.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getLocationTypeIcon(locationPoint.type),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(locationPoint.name)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('النوع', locationPoint.typeDisplayName),
            _buildDetailRow('الحالة', locationPoint.statusText),
            if (locationPoint.description != null)
              _buildDetailRow('الوصف', locationPoint.description!),
            _buildDetailRow(
              'الموقع',
              '${locationPoint.location.latitude.toStringAsFixed(6)}, ${locationPoint.location.longitude.toStringAsFixed(6)}',
            ),
            if (locationPoint.phoneNumber != null)
              _buildDetailRow('الهاتف', locationPoint.phoneNumber!),
            if (locationPoint.rating != null)
              _buildDetailRow('التقييم', '${locationPoint.rating!.toStringAsFixed(1)} / 5.0'),
            if (locationPoint.totalPrice != null)
              _buildDetailRow('السعر', '${locationPoint.totalPrice!.toStringAsFixed(2)} ج.م'),
            _buildDetailRow(
              'آخر تحديث',
              _formatDateTime(locationPoint.lastUpdated),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Show the location details dialog
  static Future<void> show(BuildContext context, LocationPoint locationPoint) {
    return showDialog(
      context: context,
      builder: (context) => LocationDetailsDialog(locationPoint: locationPoint),
    );
  }
}
