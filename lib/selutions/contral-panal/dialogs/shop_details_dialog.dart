import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class ShopDetailsDialog extends StatelessWidget {
  final Shop shop;
  final User owner;
  final AppStateManager appState;

  const ShopDetailsDialog({
    Key? key,
    required this.shop,
    required this.owner,
    required this.appState,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    Shop shop,
    User owner,
    AppStateManager appState,
  ) {
    return showDialog(
      context: context,
      builder: (context) => ShopDetailsDialog(
        shop: shop,
        owner: owner,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final shopOrders = appState.orders.where((o) => o.shopId == shop.id).toList();
    final completedOrders = shopOrders.where((o) => o.status == OrderStatus.delivered).length;
    final totalRevenue = shopOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalOrderPrice);

    return AlertDialog(
      title: Text('تفاصيل المحل: ${shop.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('اسم المحل', shop.name),
            _buildDetailRow('المالك', owner.name),
            _buildDetailRow('البريد الإلكتروني', shop.email),
            _buildDetailRow('رقم الهاتف', shop.phone),
            _buildDetailRow('العنوان', shop.address),
            _buildDetailRow(
              'الموقع',
              '${shop.location.latitude.toStringAsFixed(4)}, ${shop.location.longitude.toStringAsFixed(4)}',
            ),
            _buildDetailRow('تاريخ التسجيل', _formatDate(shop.createdAt)),
            _buildDetailRow('الحالة', shop.isActive ? 'نشط' : 'غير نشط'),
            const Divider(),
            _buildDetailRow(
              'إجمالي الطلبات',
              shopOrders.length.toString(),
            ),
            _buildDetailRow(
              'الطلبات المكتملة',
              completedOrders.toString(),
            ),
            _buildDetailRow(
              'إجمالي الإيرادات',
              '${totalRevenue.toStringAsFixed(2)} ج.م',
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
