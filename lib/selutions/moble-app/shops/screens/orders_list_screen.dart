import 'package:flutter/material.dart';
import 'package:shipping_app/logic/bloc/order_bloc.dart';
import '../../../../app-configs.dart';
import '../../../../enums.dart';
import '../../../../logic/models/models.dart';
import '../../../../logic/data/sample_data.dart';
import 'order_tracking_screen.dart';

class OrdersListScreen extends StatefulWidget {
  final String shopId;

  const OrdersListScreen({super.key, required this.shopId});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Order> orders = [];
  bool isLoading = false;
  OrdersBloc ordersBloc = OrdersBloc();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {

    if (AppConfigration.envType == EnvType.prototype) {
       orders = SampleDataProvider.getOrdersByShopId( "order_001");

    }

     ordersBloc.loadOrdersByShopId(widget.shopId);
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
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.picked_up:
        return Colors.indigo;
      case OrderStatus.on_the_way:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return Icons.hourglass_empty;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.picked_up:
        return Icons.shopping_bag;
      case OrderStatus.on_the_way:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadOrders();
        },
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : orders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد طلبات حالياً',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OrderTrackingScreen(order: order),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'طلب رقم: ${order.shopId}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(order.status),
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getOrderStatusDisplayName(order.status),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'العميل: ${order.recipientDetails.name}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'الهاتف: ${order.recipientDetails.phone}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'إجمالي: ${order.totalOrderPrice.toStringAsFixed(2)} جنيه',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
