import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipping_app/logic/models/models.dart';
import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_builder.dart';
import 'package:shipping_app/logic/bloc/drivers_bloc.dart';
import 'package:shipping_app/app-configs.dart';
import 'package:shipping_app/enums.dart';
import '../../../logic/provider/app_state_manager.dart';
import '../../../logic/data/sample_data.dart';

class DriversManagementScreen extends StatefulWidget {
  const DriversManagementScreen({Key? key}) : super(key: key);

  @override
  State<DriversManagementScreen> createState() =>
      _DriversManagementScreenState();
}

class _DriversManagementScreenState extends State<DriversManagementScreen> {
  DriverStatus? _selectedStatus;
  late DriversBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = DriversBloc();
    
    // Only load data if not in prototype mode
    if (AppConfigration.envType != EnvType.prototype) {
      bloc.loadDrivers();
    }
  }

  @override
  Widget build(BuildContext context) {
    // For prototype mode, use AppStateManager directly
    if (AppConfigration.envType == EnvType.prototype) {
      return Consumer<AppStateManager>(
        builder: (context, appState, child) {
          return _buildContent(context, appState.drivers);
        },
      );
    }

    // For production mode, use DataSourceBlocBuilder
    return DataSourceBlocBuilder<List<Driver>>(
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      bloc: bloc.listDriversBloc,
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

  Widget _buildContent(BuildContext context, List<Driver> drivers) {
        // Apply local filtering
        final filteredDrivers = drivers.where((driver) {
          bool matchesStatus = _selectedStatus == null || driver.status == _selectedStatus;
          return matchesStatus;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط الأدوات
              Row(
                children: [
                  // فلتر الحالة
                  DropdownButton<DriverStatus?>(
                    value: _selectedStatus,
                    hint: const Text('جميع الحالات'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('جميع الحالات'),
                      ),
                      ...DriverStatus.values.map((status) {
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
                  const SizedBox(width: 16),

                  // زر تحديث المواقع
                  ElevatedButton.icon(
                    onPressed: () {
                      // محاكاة تحديث المواقع
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث مواقع السائقين'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحديث المواقع'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // الإحصائيات السريعة
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي السائقين',
                      value: drivers.length.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'السائقين المتاحين',
                      value:
                          drivers
                              .where((d) => d.status == DriverStatus.available)
                              .length
                              .toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'السائقين المشغولين',
                      value:
                          drivers
                              .where((d) => d.status == DriverStatus.busy)
                              .length
                              .toString(),
                      icon: Icons.work,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'في نقطة التجمع',
                      value:
                          drivers
                              .where(
                                (d) => d.status == DriverStatus.at_rally_point,
                              )
                              .length
                              .toString(),
                      icon: Icons.location_on,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // عداد النتائج
              Text(
                'عدد السائقين: ${filteredDrivers.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // جدول السائقين
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('الاسم')),
                        DataColumn(label: Text('رقم الهاتف')),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('التقييم')),
                        DataColumn(label: Text('الموقع الحالي')),
                        DataColumn(label: Text('آخر تحديث')),
                        DataColumn(label: Text('الطلبات النشطة')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows:
                          filteredDrivers.map((driver) {
                            // For active orders count, we'll use a placeholder for now
                            // since we don't have access to orders data in production mode
                            final activeOrders = 0; // This would need to be calculated differently

                            return DataRow(
                              cells: [
                                DataCell(Text(driver.name ?? 'غير محدد')),
                                DataCell(Text(driver.phone ?? 'غير محدد')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        driver.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusDisplayName(driver.status),
                                      style: TextStyle(
                                        color: _getStatusColor(driver.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(driver.rating.toStringAsFixed(1)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                            driver.  currentLocation != null?
                                    '${driver.currentLocation!.latitude.toStringAsFixed(4)}, ${driver.currentLocation!.longitude.toStringAsFixed(4)}'
                            :                                  'غير محدد'
                            ,
                                  ),
                                ),
                                DataCell(
                                driver.  lastLocationUpdate != null ?
                                  Text(_formatDate(driver.lastLocationUpdate) )
                            : const Text('غير محدد'),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          activeOrders > 0
                                              ? Colors.red.shade100
                                              : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      activeOrders.toString(),
                                      style: TextStyle(
                                        color:
                                            activeOrders > 0
                                                ? Colors.red.shade800
                                                : Colors.green.shade800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () => _showDriverDetails(
                                          context,
                                          driver,
                                        ),
                                        tooltip: 'عرض التفاصيل',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.location_on),
                                        onPressed: () => _showDriverLocation(
                                          context,
                                          driver,
                                        ),
                                        tooltip: 'عرض الموقع على الخريطة',
                                      ),
                                      PopupMenuButton<String>(
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'change_status',
                                                child: Text('تغيير الحالة'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'view_orders',
                                                child: Text('عرض الطلبات'),
                                              ),
                                            ],
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'change_status':
                                              _showChangeStatusDialog(
                                                context,
                                                driver,
                                              );
                                              break;
                                            case 'view_orders':
                                              _showDriverOrders(
                                                context,
                                                driver,
                                              );
                                              break;
                                          }
                                        },
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
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return Colors.green;
      case DriverStatus.busy:
        return Colors.red;
      case DriverStatus.at_rally_point:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDriverDetails(
    BuildContext context,
    Driver driver,
  ) {
    // For orders data, we'll use sample data as fallback since we don't have AppStateManager
    final driverOrders = SampleDataProvider.getOrdersByDriverId(driver.id!);
    final completedOrders =
        driverOrders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders =
        driverOrders.where((o) => o.status == OrderStatus.cancelled).length;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تفاصيل السائق: ${driver.name ?? 'غير محدد'}'),
            content: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('الاسم', driver.name ?? 'غير محدد'),
                  _buildDetailRow('البريد الإلكتروني', driver.email ?? 'غير محدد'),
                  _buildDetailRow('رقم الهاتف', driver.phone ?? 'غير محدد'),
                  _buildDetailRow(
                    'الحالة',
                    _getStatusDisplayName(driver.status),
                  ),
                  _buildDetailRow(
                    'التقييم',
                    '${driver.rating.toStringAsFixed(1)} / 5.0',
                  ),
                  _buildDetailRow(
                    'الموقع الحالي',
                    '${driver.currentLocation!.latitude.toStringAsFixed(4)}, ${driver.currentLocation!.longitude.toStringAsFixed(4)}',
                  ),
                  if (driver.rallyPoint != null)
                    _buildDetailRow(
                      'نقطة التجمع',
                      '${driver.rallyPoint!.latitude.toStringAsFixed(4)}, ${driver.rallyPoint!.longitude.toStringAsFixed(4)}',
                    ),
                  _buildDetailRow(
                    'آخر تحديث للموقع',
                    _formatDate(driver.lastLocationUpdate),
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'إجمالي الطلبات',
                    driverOrders.length.toString(),
                  ),
                  _buildDetailRow(
                    'الطلبات المكتملة',
                    completedOrders.toString(),
                  ),
                  _buildDetailRow(
                    'الطلبات الملغاة',
                    cancelledOrders.toString(),
                  ),
                  _buildDetailRow(
                    'معدل الإنجاز',
                    driverOrders.isNotEmpty
                        ? '${((completedOrders / driverOrders.length) * 100).toStringAsFixed(1)}%'
                        : '0%',
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

  void _showDriverLocation(BuildContext context, Driver driver) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('موقع السائق: ${driver.name ?? 'غير محدد'}'),
            content: SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  Text('الموقع الحالي:'),
                  Text(
                    'خط العرض: ${driver.currentLocation!.latitude.toStringAsFixed(6)}',
                  ),
                  Text(
                    'خط الطول: ${driver.currentLocation!.longitude.toStringAsFixed(6)}',
                  ),
                  const SizedBox(height: 16),
                  if (driver.rallyPoint != null) ...[
                    Text('نقطة التجمع:'),
                    Text(
                      'خط العرض: ${driver.rallyPoint!.latitude.toStringAsFixed(6)}',
                    ),
                    Text(
                      'خط الطول: ${driver.rallyPoint!.longitude.toStringAsFixed(6)}',
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('آخر تحديث: ${_formatDate(driver.lastLocationUpdate)}'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'خريطة Google Maps\n(سيتم تفعيلها لاحقاً)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
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
          ),
    );
  }

  void _showChangeStatusDialog(
    BuildContext context,
    Driver driver,
  ) {
    DriverStatus selectedStatus = driver.status;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('تغيير حالة السائق: ${driver.name ?? 'غير محدد'}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<DriverStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'الحالة الجديدة',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            DriverStatus.values.map((status) {
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
                        // For now, just show success message
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديث حالة السائق بنجاح'),
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

  void _showDriverOrders(
    BuildContext context,
    Driver driver,
  ) {
    final driverOrders = SampleDataProvider.getOrdersByDriverId(driver.id!);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('طلبات السائق: ${driver.name ?? 'غير محدد'}'),
            content: SizedBox(
              width: 600,
              height: 400,
              child:
                  driverOrders.isEmpty
                      ? const Center(child: Text('لا توجد طلبات لهذا السائق'))
                      : ListView.builder(
                        itemCount: driverOrders.length,
                        itemBuilder: (context, index) {
                          final order = driverOrders[index];
                          // Get shop name from sample data
                          final shop = SampleDataProvider.getShopById(order.shopId);
                          return Card(
                            child: ListTile(
                              title: Text('الطلب ${order.shopId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المحل: ${shop?.userName ?? 'غير محدد'}',
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
}
