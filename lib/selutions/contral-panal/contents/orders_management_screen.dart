import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipping_app/logic/models/order.dart';
import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_builder.dart';
import 'package:shipping_app/logic/bloc/order_bloc.dart';
import 'package:shipping_app/app-configs.dart';
import 'package:shipping_app/enums.dart';

import '../../../logic/provider/app_state_manager.dart';
import '../../../logic/data/sample_data.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({Key? key}) : super(key: key);

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  OrderStatus? _selectedStatus;
  String? _selectedShopId;
  String? _selectedDriverId;
  DateTime? _startDate;
  DateTime? _endDate;
  late OrdersBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = OrdersBloc();
    
    // Only load data if not in prototype mode
    if (AppConfigration.envType != EnvType.prototype) {
      bloc.loadAllOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    // For prototype mode, use AppStateManager directly
    if (AppConfigration.envType == EnvType.prototype) {
      return Consumer<AppStateManager>(
        builder: (context, appState, child) {
          return _buildContent(context, appState.orders);
        },
      );
    }

    // For production mode, use DataSourceBlocBuilder
    return DataSourceBlocBuilder<List<Order>>(
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      bloc: bloc.listOrdersBloc,
      failure: (error, retry) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'حدث خطأ أثناء تحميل البيانات: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: retry,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
      },
      success: (data) {
        return _buildContent(context, data ?? []);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Order> orders) {
        // Apply local filtering
        final filteredOrders = orders.where((order) {
          bool matchesStatus = _selectedStatus == null || order.status == _selectedStatus;
          bool matchesShop = _selectedShopId == null || order.shopId == _selectedShopId;
          bool matchesDriver = _selectedDriverId == null || order.driverId == _selectedDriverId;
          bool matchesDateRange = true;
          
          if (_startDate != null || _endDate != null) {
            if (_startDate != null && order.createdAt.isBefore(_startDate!)) {
              matchesDateRange = false;
            }
            if (_endDate != null && order.createdAt.isAfter(_endDate!)) {
              matchesDateRange = false;
            }
          }
          
          return matchesStatus && matchesShop && matchesDriver && matchesDateRange;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط الفلاتر
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فلاتر البحث',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          // فلتر الحالة
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<OrderStatus?>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'الحالة',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('جميع الحالات'),
                                ),
                                ...OrderStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(_getStatusDisplayName(status)),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              },
                            ),
                          ),

                          // فلتر المحل
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String?>(
                              value: _selectedShopId,
                              decoration: const InputDecoration(
                                labelText: 'المحل',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('جميع المحلات'),
                                ),
                                ...SampleDataProvider.getShops().map((shop) {
                                  return DropdownMenuItem(
                                    value: shop.shopId,
                                    child: Text(shop.userName),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedShopId = value;
                                });
                              },
                            ),
                          ),

                          // فلتر السائق
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String?>(
                              value: _selectedDriverId,
                              decoration: const InputDecoration(
                                labelText: 'السائق',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('جميع السائقين'),
                                ),
                                ...SampleDataProvider.getDrivers().map((driver) {
                                  return DropdownMenuItem(
                                    value: driver.id,
                                    child: Text(driver.name ?? 'غير محدد'),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDriverId = value;
                                });
                              },
                            ),
                          ),

                          // زر إعادة تعيين الفلاتر
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatus = null;
                                _selectedShopId = null;
                                _selectedDriverId = null;
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            child: const Text('إعادة تعيين'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // عداد النتائج
              Text(
                'عدد الطلبات: ${filteredOrders.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // جدول الطلبات
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('رقم الطلب')),
                        DataColumn(label: Text('المحل')),
                        DataColumn(label: Text('العميل')),
                        DataColumn(label: Text('إجمالي السعر')),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('السائق')),
                        DataColumn(label: Text('تاريخ الإنشاء')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows:
                          filteredOrders.map((order) {
                            return DataRow(
                              cells: [
                                DataCell(Text(order.shopId)),
                                DataCell(
                                  Text(SampleDataProvider.getShopById(order.shopId)?.userName ?? 'غير محدد'),
                                ),
                                DataCell(Text(order.recipientDetails.name)),
                                DataCell(
                                  Text(
                                    '${order.totalOrderPrice.toStringAsFixed(2)} ج.م',
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        order.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusDisplayName(order.status),
                                      style: TextStyle(
                                        color: _getStatusColor(order.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    order.driverId != null
                                        ? SampleDataProvider.getDriverById(order.driverId!)?.name ?? 'غير محدد'
                                        : 'غير محدد',
                                  ),
                                ),
                                DataCell(Text(_formatDate(order.createdAt))),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed:
                                            () => _showOrderDetails(
                                              context,
                                              order,
                                            ),
                                        tooltip: 'عرض التفاصيل',
                                      ),
                                      if (order.status ==
                                          OrderStatus.pending_acceptance)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.assignment_ind,
                                          ),
                                          onPressed:
                                              () => _showAssignDriverDialog(
                                                context,
                                                order,
                                              ),
                                          tooltip: 'تعيين سائق',
                                        ),
                                      if (order.status !=
                                              OrderStatus.delivered &&
                                          order.status != OrderStatus.cancelled)
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed:
                                              () => _showEditOrderDialog(
                                                context,
                                                order,
                                              ),
                                          tooltip: 'تعديل الحالة',
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
                            ],
          ),
        );
  }  String _getStatusDisplayName(OrderStatus status) {
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.picked_up:
        return Colors.purple;
      case OrderStatus.on_the_way:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderDetails(
    BuildContext context,
    Order order,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      SampleDataProvider.getShopById(order.shopId)?.userName ?? 'غير محدد',
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
                        SampleDataProvider.getDriverById(order.driverId!)?.name ?? 'غير محدد',
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

  void _showAssignDriverDialog(
    BuildContext context,
    Order order,
  ) {
    final availableDrivers = SampleDataProvider.getAvailableDrivers();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تعيين سائق للطلب'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('الطلب: ${order.shopId}'),
                  Text('المحل: ${SampleDataProvider.getShopById(order.shopId)?.userName ?? 'غير محدد'}'),
                  Text('العميل: ${order.recipientDetails.name}'),
                  const SizedBox(height: 16),
                  const Text('السائقين المتاحين:'),
                  const SizedBox(height: 8),
                  ...availableDrivers.map((driver) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(driver.name ?? 'غير محدد'),
                      subtitle: Text(
                        'التقييم: ${driver.rating.toStringAsFixed(1)}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // TODO: In production, this would update via bloc
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
          ),
    );
  }

  void _showEditOrderDialog(
    BuildContext context,
    Order order,
  ) {
    OrderStatus selectedStatus = order.status;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('تعديل حالة الطلب'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('الطلب: ${order.shopId}'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<OrderStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'الحالة الجديدة',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            OrderStatus.values.map((status) {
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
                        // TODO: In production, this would update via bloc
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
                ),
          ),
    );
  }
}
