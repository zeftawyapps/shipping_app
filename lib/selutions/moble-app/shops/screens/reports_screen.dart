import 'package:flutter/material.dart';
import '../../../../logic/models/models.dart';
import '../../../../logic/data/sample_data.dart';

class ReportsScreen extends StatefulWidget {
  final String shopId;

  const ReportsScreen({super.key, required this.shopId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Order> deliveredOrders = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _isLoading = true;
    });

    // محاكاة تحميل البيانات
    Future.delayed(const Duration(seconds: 1), () {
      List<Order> allDeliveredOrders = SampleDataProvider.getOrdersByShopId(widget.shopId)
          .where((order) => order.status == OrderStatus.delivered)
          .toList();
      
      // تطبيق فلتر التاريخ إذا كان محدد
      if (_startDate != null && _endDate != null) {
        allDeliveredOrders = allDeliveredOrders.where((order) {
          return order.deliveredAt != null &&
              order.deliveredAt!.isAfter(_startDate!) &&
              order.deliveredAt!.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      }

      setState(() {
        deliveredOrders = allDeliveredOrders;
        _isLoading = false;
      });
    });
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReports();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadReports();
  }

  double _calculateTotalRevenue() {
    return deliveredOrders.fold(0.0, (sum, order) => sum + order.totalOrderPrice);
  }

  int _getTotalOrders() {
    return deliveredOrders.length;
  }

  double _getAverageOrderValue() {
    if (deliveredOrders.isEmpty) return 0;
    return _calculateTotalRevenue() / deliveredOrders.length;
  }

  Map<String, int> _getOrdersByMonth() {
    Map<String, int> monthlyOrders = {};
    
    for (var order in deliveredOrders) {
      if (order.deliveredAt != null) {
        String monthKey = '${order.deliveredAt!.year}-${order.deliveredAt!.month.toString().padLeft(2, '0')}';
        monthlyOrders[monthKey] = (monthlyOrders[monthKey] ?? 0) + 1;
      }
    }
    
    return monthlyOrders;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // فلاتر التاريخ
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'فلتر الفترة الزمنية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _selectDateRange,
                                  icon: const Icon(Icons.date_range),
                                  label: Text(
                                    _startDate != null && _endDate != null
                                        ? 'من ${_formatDate(_startDate!)} إلى ${_formatDate(_endDate!)}'
                                        : 'اختيار الفترة الزمنية',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_startDate != null && _endDate != null)
                                IconButton(
                                  onPressed: _clearDateFilter,
                                  icon: const Icon(Icons.clear),
                                  tooltip: 'مسح الفلتر',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ملخص الإحصائيات
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الطلبات',
                          _getTotalOrders().toString(),
                          Icons.shopping_bag,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'إجمالي الإيرادات',
                          '${_calculateTotalRevenue().toStringAsFixed(2)} جنيه',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'متوسط قيمة الطلب',
                          '${_getAverageOrderValue().toStringAsFixed(2)} جنيه',
                          Icons.analytics,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'معدل التوصيل',
                          '100%',
                          Icons.check_circle,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // الطلبات الشهرية
                  if (_getOrdersByMonth().isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الطلبات حسب الشهر',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._getOrdersByMonth().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${entry.value} طلب',
                                        style: TextStyle(
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // قائمة الطلبات المفصلة
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل الطلبات المتوصلة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (deliveredOrders.isEmpty)
                            const Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'لا توجد طلبات موصلة في الفترة المحددة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: deliveredOrders.length,
                              itemBuilder: (context, index) {
                                final order = deliveredOrders[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'الطلب رقم: ${order.shopId}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'تم التوصيل',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: Colors.grey),
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
                                            const Icon(Icons.attach_money, size: 16, color: Colors.green),
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
                                        
                                        const SizedBox(height: 4),
                                        
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              'تاريخ التوصيل: ${order.deliveredAt != null ? _formatDate(order.deliveredAt!) : "غير محدد"}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        if (order.items.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          const Divider(),
                                          const Text(
                                            'المحتويات:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          ...order.items.map((item) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Text(
                                              '• ${item.name} (${item.quantity}x) - ${item.totalPrice.toStringAsFixed(2)} جنيه',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          )),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
