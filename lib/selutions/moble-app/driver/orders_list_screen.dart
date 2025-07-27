import 'package:flutter/material.dart';
import '../../../logic/models/models.dart';
import '../../../logic/data/sample_data.dart';
import 'order_tracking_screen.dart';

class OrdersListScreen extends StatefulWidget {
  final Users driver;

  const OrdersListScreen({super.key, required this.driver});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Order> availableOrders = [];
  List<Order> myOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _isLoading = true;
    });

    // محاكاة تحميل البيانات
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        availableOrders = SampleDataProvider.getOrders()
            .where((order) => order.status == OrderStatus.pending_acceptance)
            .toList();
        myOrders = SampleDataProvider.getOrders()
            .where((order) => order.driverId == widget.driver.id)
            .toList();
        _isLoading = false;
      });
    });
  }

  Future<void> _acceptOrder(Order order) async {
    try {
      // تحديث حالة الطلب - محاكاة فقط
      // في التطبيق الحقيقي، سيتم إرسال طلب إلى الخادم
      
      // إعادة تحميل البيانات
      _loadOrders();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم قبول الطلب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // الانتقال لشاشة تتبع الطلب
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
            order: order,
            driver: widget.driver,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectOrder(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم رفض الطلب'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navigateToOrderTracking(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(
          order: order,
          driver: widget.driver,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('الطلبات'),
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadOrders,
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.green[200],
            tabs: [
              Tab(
                icon: Icon(Icons.assignment),
                text: 'الطلبات المتاحة (${availableOrders.length})',
              ),
              Tab(
                icon: Icon(Icons.local_shipping),
                text: 'طلباتي (${myOrders.length})',
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAvailableOrdersList(),
                  _buildMyOrdersList(),
                ],
              ),
      ),
    );
  }

  Widget _buildAvailableOrdersList() {
    if (availableOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات متاحة حالياً',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر الطلبات الجديدة هنا',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: availableOrders.length,
        itemBuilder: (context, index) {
          final order = availableOrders[index];
          return _buildOrderCard(order, isAvailable: true);
        },
      ),
    );
  }

  Widget _buildMyOrdersList() {
    if (myOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات مُسندة إليك',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اقبل طلبات من التبويب الأول',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myOrders.length,
        itemBuilder: (context, index) {
          final order = myOrders[index];
          return _buildOrderCard(order, isAvailable: false);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, {required bool isAvailable}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getOrderStatusDisplayName(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'طلب رقم: ${order.id.substring(order.id.length - 3)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // تفاصيل المحل
            Row(
              children: [
                Icon(Icons.store, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.senderDetails.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order.senderDetails.phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // تفاصيل العميل
            Row(
              children: [
                Icon(Icons.person, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.recipientDetails.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order.recipientDetails.phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // عناصر الطلب
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عناصر الطلب:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} × ${item.quantity}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Text(
                              '${item.totalPrice.toStringAsFixed(2)} جنيه',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'الإجمالي:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${order.totalOrderPrice.toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // أزرار التحكم
            if (isAvailable)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptOrder(order),
                      icon: const Icon(Icons.check),
                      label: const Text('قبول'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectOrder(order),
                      icon: const Icon(Icons.close),
                      label: const Text('رفض'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[600]!),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToOrderTracking(order),
                  icon: const Icon(Icons.track_changes),
                  label: const Text('تتبع الطلب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
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
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return Colors.orange[600]!;
      case OrderStatus.accepted:
        return Colors.blue[600]!;
      case OrderStatus.picked_up:
        return Colors.indigo[600]!;
      case OrderStatus.on_the_way:
        return Colors.cyan[600]!;
      case OrderStatus.delivered:
        return Colors.green[600]!;
      case OrderStatus.cancelled:
        return Colors.red[600]!;
    }
  }
}
