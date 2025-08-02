import 'package:flutter/material.dart';
import '../../../../logic/models/models.dart';
import '../../../../logic/data/sample_data.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Driver? driver;

  @override
  void initState() {
    super.initState();
    if (widget.order.driverId != null) {
      driver = SampleDataProvider.getDriverById(widget.order.driverId!);
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

  String _getDriverStatusDisplayName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  List<Map<String, dynamic>> _getOrderSteps() {
    return [
      {
        'title': 'تم إنشاء الطلب',
        'subtitle': 'تم إنشاء الطلب بنجاح',
        'icon': Icons.check_circle,
        'isCompleted': true,
        'date': widget.order.createdAt,
      },
      {
        'title': 'بانتظار القبول',
        'subtitle': 'في انتظار قبول سائق للطلب',
        'icon': Icons.hourglass_empty,
        'isCompleted': widget.order.status != OrderStatus.pending_acceptance,
        'date': widget.order.acceptedAt,
      },
      {
        'title': 'السائق في الطريق للمحل',
        'subtitle': 'السائق متوجه لاستلام الطلب',
        'icon': Icons.directions_car,
        'isCompleted': widget.order.status == OrderStatus.picked_up ||
            widget.order.status == OrderStatus.on_the_way ||
            widget.order.status == OrderStatus.delivered,
        'date': null,
      },
      {
        'title': 'تم استلام الطلب',
        'subtitle': 'تم استلام الطلب من المحل',
        'icon': Icons.shopping_bag,
        'isCompleted': widget.order.status == OrderStatus.picked_up ||
            widget.order.status == OrderStatus.on_the_way ||
            widget.order.status == OrderStatus.delivered,
        'date': widget.order.pickedUpAt,
      },
      {
        'title': 'الطلب في الطريق',
        'subtitle': 'السائق في طريقه للعميل',
        'icon': Icons.local_shipping,
        'isCompleted': widget.order.status == OrderStatus.on_the_way ||
            widget.order.status == OrderStatus.delivered,
        'date': null,
      },
      {
        'title': 'تم التوصيل',
        'subtitle': 'تم توصيل الطلب بنجاح',
        'icon': Icons.check_circle_outline,
        'isCompleted': widget.order.status == OrderStatus.delivered,
        'date': widget.order.deliveredAt,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getOrderSteps();

    return Scaffold(
      appBar: AppBar(
        title: Text('تتبع الطلب ${widget.order.shopId}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حالة الطلب الحالية
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.order.status),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'حالة الطلب الحالية',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _getOrderStatusDisplayName(widget.order.status),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(widget.order.status),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // معلومات السائق (إذا كان متوفر)
            if (driver != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معلومات السائق',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'السائق المعين',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  SampleDataProvider.getUserById(driver!.id !)?.name ?? 'غير محدد',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      driver!.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: driver!.status == DriverStatus.available
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getDriverStatusDisplayName(driver!.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ميزة عرض الخريطة قيد التطوير'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('عرض موقع السائق على الخريطة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // خط زمني لحالة الطلب
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تتبع مسار الطلب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: steps.length,
                      itemBuilder: (context, index) {
                        final step = steps[index];
                        final isLast = index == steps.length - 1;
                        
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: step['isCompleted']
                                        ? Colors.green
                                        : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    step['icon'],
                                    size: 16,
                                    color: step['isCompleted']
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: step['isCompleted']
                                        ? Colors.green
                                        : Colors.grey[300],
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['title'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: step['isCompleted']
                                            ? Colors.green
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      step['subtitle'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (step['date'] != null)
                                      Text(
                                        '${step['date'].day}/${step['date'].month}/${step['date'].year} - ${step['date'].hour}:${step['date'].minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // معلومات الطلب
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تفاصيل الطلب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildDetailRow('العميل:', widget.order.recipientDetails.name),
                    _buildDetailRow('الهاتف:', widget.order.recipientDetails.phone),
                    if (widget.order.recipientDetails.email != null)
                      _buildDetailRow('البريد الإلكتروني:', widget.order.recipientDetails.email!),
                    _buildDetailRow('إجمالي الطلب:', '${widget.order.totalOrderPrice.toStringAsFixed(2)} جنيه'),
                    
                    const SizedBox(height: 12),
                    const Divider(),
                    const Text(
                      'محتويات الطلب:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.name} (${item.quantity}x)'),
                          Text('${item.totalPrice.toStringAsFixed(2)} جنيه'),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
