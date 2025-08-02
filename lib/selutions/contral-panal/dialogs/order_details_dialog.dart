import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class OrderDetailsDialog extends StatelessWidget {
  final Order order;
  final AppStateManager appState;

  const OrderDetailsDialog({
    Key? key,
    required this.order,
    required this.appState,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context,
    Order order,
    AppStateManager appState,
  ) {
    return showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(
        order: order,
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

  String _getStatusDisplayName(OrderStatus status) {
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تفاصيل الطلب ${order.shopId}'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'المحل',
                appState.getShopName(order.shopId),
              ),
              _buildDetailRow('هاتف المحل', order.senderDetails.phone),
              const Divider(),
              _buildDetailRow('العميل', order.recipientDetails.name),
              _buildDetailRow(
                'هاتف العميل',
                order.recipientDetails.phone,
              ),
              if (order.recipientDetails.email != null)
                _buildDetailRow(
                  'بريد العميل',
                  order.recipientDetails.email!,
                ),
              const Divider(),
              _buildDetailRow(
                'الحالة',
                _getStatusDisplayName(order.status),
              ),
              if (order.driverId != null)
                _buildDetailRow(
                  'السائق',
                  appState.getUserName(order.driverId!),
                ),
              _buildDetailRow(
                'تاريخ الإنشاء',
                _formatDate(order.createdAt),
              ),
              if (order.acceptedAt != null)
                _buildDetailRow(
                  'تاريخ القبول',
                  _formatDate(order.acceptedAt!),
                ),
              if (order.pickedUpAt != null)
                _buildDetailRow(
                  'تاريخ الاستلام',
                  _formatDate(order.pickedUpAt!),
                ),
              if (order.deliveredAt != null)
                _buildDetailRow(
                  'تاريخ التسليم',
                  _formatDate(order.deliveredAt!),
                ),
              if (order.cancelledAt != null)
                _buildDetailRow(
                  'تاريخ الإلغاء',
                  _formatDate(order.cancelledAt!),
                ),
              if (order.cancellationReason != null)
                _buildDetailRow('سبب الإلغاء', order.cancellationReason!),
              const Divider(),
              const Text(
                'الأصناف:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('• ${item.name}'),
                      const Spacer(),
                      Text(
                        '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} = ${item.totalPrice.toStringAsFixed(2)} ج.م',
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              _buildDetailRow(
                'الإجمالي',
                '${order.totalOrderPrice.toStringAsFixed(2)} ج.م',
              ),
            ],
          ),
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
