import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';

class DriverLocationDialog extends StatelessWidget {
  final Driver driver;
  final Users user;

  const DriverLocationDialog({
    Key? key,
    required this.driver,
    required this.user,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    Driver driver,
    Users user,
  ) {
    return showDialog(
      context: context,
      builder: (context) => DriverLocationDialog(
        driver: driver,
        user: user,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('موقع السائق: ${user.name}'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            Text('الموقع الحالي:'),
            Text(
              'خط العرض: ${driver.currentLocation!.latitude.toStringAsFixed(6)}',
            ),
            Text(
              'خط الطول: ${driver.currentLocation!.longitude.toStringAsFixed(6)}',
            ),
            if (driver.rallyPoint != null) ...[
              const SizedBox(height: 16),
              const Text('نقطة التجمع:'),
              Text(
                'خط العرض: ${driver.rallyPoint!.latitude.toStringAsFixed(6)}',
              ),
              Text(
                'خط الطول: ${driver.rallyPoint!.longitude.toStringAsFixed(6)}',
              ),
            ],
            const SizedBox(height: 16),
            Text('آخر تحديث: ${_formatDate(driver.lastLocationUpdate)}'),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'خريطة Google Maps\n(سيتم تفعيلها لاحقاً)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
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
