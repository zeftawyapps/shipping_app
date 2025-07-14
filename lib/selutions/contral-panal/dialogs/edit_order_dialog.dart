import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';

class EditOrderDialog extends StatefulWidget {
  final Order order;
  final AppStateManager appState;

  const EditOrderDialog({
    Key? key,
    required this.order,
    required this.appState,
  }) : super(key: key);

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();

  static Future<void> show(
    BuildContext context,
    AppStateManager appState,
    Order order,
  ) {
    return showDialog(
      context: context,
      builder: (context) => EditOrderDialog(
        order: order,
        appState: appState,
      ),
    );
  }
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late OrderStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.status;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل حالة الطلب'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('الطلب: ${widget.order.id}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<OrderStatus>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'الحالة الجديدة',
              border: OutlineInputBorder(),
            ),
            items: OrderStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(_getStatusDisplayName(status)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedStatus = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.appState.updateOrderStatus(widget.order.id, selectedStatus);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث حالة الطلب بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('تحديث'),
        ),
      ],
    );
  }
}
