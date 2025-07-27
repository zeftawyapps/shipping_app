import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      orders = SampleDataProvider.getOrdersByShopId(widget.shopId);
    });
  }

  void _showOrderOptions(Order order) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الطلب رقم: ${order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (order.status == OrderStatus.pending_acceptance ||
                  order.status == OrderStatus.accepted)
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('إلغاء الطلب'),
                  onTap: () {
                    Navigator.pop(context);
                    _cancelOrder(order);
                  },
                ),
              
              if (order.status == OrderStatus.cancelled ||
                  order.status == OrderStatus.delivered)
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.blue),
                  title: const Text('إعادة إرسال الطلب'),
                  onTap: () {
                    Navigator.pop(context);
                    _resendOrder(order);
                  },
                ),
              
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: const Text('تتبع الطلب'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingScreen(order: order),
                    ),
                  );
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('إغلاق'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final reasonController = TextEditingController();
        
        return AlertDialog(
          title: const Text('إلغاء الطلب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'سبب الإلغاء',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                // TODO: Implement real order cancellation
                // SampleDataProvider doesn't have cancelOrder method
                /*
                MockData.cancelOrder(
                  order.id, 
                  reasonController.text.isEmpty 
                      ? 'تم الإلغاء من قبل المحل' 
                      : reasonController.text,
                );
                */
                Navigator.of(context).pop();
                _loadOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إلغاء الطلب بنجاح'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        );
      },
    );
  }

  void _resendOrder(Order order) {
    // TODO: Implement real order re-creation
    /*
    final newOrder = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      shopId: order.shopId,
      driverId: null,
      senderDetails: order.senderDetails,
      recipientDetails: order.recipientDetails,
      items: order.items,
      totalOrderPrice: order.totalOrderPrice,
      status: OrderStatus.pending_acceptance,
      createdAt: DateTime.now(),
      acceptedAt: null,
      pickedUpAt: null,
      deliveredAt: null,
      cancelledAt: null,
      cancellationReason: null,
    );
    
    // SampleDataProvider doesn't have addOrder method
    // MockData.addOrder(newOrder);
    */
    
    _loadOrders();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة إرسال الطلب بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadOrders();
        },
        child: orders.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
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
                      onTap: () => _showOrderOptions(order),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الطلب رقم: ${order.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                                        size: 16,
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
                            
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'العميل: ${order.recipientDetails.name}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order.recipientDetails.phone,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Row(
                              children: [
                                const Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${order.totalOrderPrice.toStringAsFixed(2)} جنيه',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'تاريخ الإنشاء: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} - ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            
                            if (order.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Divider(),
                              const Text(
                                'المحتويات:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...order.items.take(2).map((item) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '• ${item.name} (${item.quantity}x)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              )),
                              if (order.items.length > 2)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '... و ${order.items.length - 2} عنصر آخر',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
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
