import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class DriverOrdersDialog extends StatelessWidget {
  final Driver driver;
  final Users user;
  final AppStateManager appState;

  const DriverOrdersDialog({
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
      builder: (context) => DriverOrdersDialog(
        driver: driver,
        user: user,
        appState: appState,
      ),
    );
  }

  String _getOrderStatusDisplayName(OrderStatus status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final driverOrders = appState.orders.where((o) => o.driverId == driver.id).toList();

    return AlertDialog(
      title: Text('طلبات السائق: ${user.name}'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: driverOrders.isEmpty
            ? const Center(child: Text('لا توجد طلبات لهذا السائق'))
            : ListView.builder(
                itemCount: driverOrders.length,
                itemBuilder: (context, index) {
                  final order = driverOrders[index];
                  return Card(
                    child: ListTile(
                      title: Text('الطلب ${order.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المحل: ${appState.getShopName(order.shopId)}',
                          ),
                          Text(
                            'العميل: ${order.recipientDetails.name}',
                          ),
                          Text(
                            'الحالة: ${_getOrderStatusDisplayName(order.status)}',
                          ),
                          Text(
                            'التاريخ: ${_formatDate(order.createdAt)}',
                          ),
                        ],
                      ),
                      trailing: Text(
                        '${order.totalOrderPrice.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
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
