import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class AssignDriverDialog extends StatelessWidget {
  final Order order;
  final AppStateManager appState;

  const AssignDriverDialog({
    Key? key,
    required this.order,
    required this.appState,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    AppStateManager appState,
    Order order,
  ) {
    return showDialog(
      context: context,
      builder: (context) => AssignDriverDialog(
        order: order,
        appState: appState,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableDrivers = appState.getFilteredDrivers(
      status: DriverStatus.available,
    );

    return AlertDialog(
      title: const Text('تعيين سائق للطلب'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الطلب: ${order.id}'),
            Text('المحل: ${appState.getShopName(order.shopId)}'),
            Text('العميل: ${order.recipientDetails.name}'),
            const SizedBox(height: 16),
            const Text('السائقين المتاحين:'),
            const SizedBox(height: 8),
            if (availableDrivers.isEmpty)
              const Text('لا يوجد سائقين متاحين حالياً')
            else
              ...availableDrivers.map((driver) {
                final user = appState.users.firstWhere(
                  (u) => u.id == driver.id,
                );
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.name),
                  subtitle: Text(
                    'التقييم: ${driver.rating.toStringAsFixed(1)}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      appState.assignDriverToOrder(order.id, driver.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تعيين السائق بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('تعيين'),
                  ),
                );
              }).toList(),
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
