import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_builder.dart';
import 'package:shipping_app/logic/bloc/shopes_bloc.dart';
import 'package:shipping_app/app-configs.dart';
import 'package:shipping_app/enums.dart';

import '../../../logic/models/models.dart';
import '../../../logic/provider/app_state_manager.dart';
import '../../../logic/data/sample_data.dart';

class ShopsManagementScreen extends StatefulWidget {
  const ShopsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ShopsManagementScreen> createState() => _ShopsManagementScreenState();
}

class _ShopsManagementScreenState extends State<ShopsManagementScreen> {
  late ShopesBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = ShopesBloc();
    
    // Only load data if not in prototype mode
    if (AppConfigration.envType != EnvType.prototype) {
      bloc.loadShops();
    }
  }

  @override
  Widget build(BuildContext context) {
    // For prototype mode, use AppStateManager directly
    if (AppConfigration.envType == EnvType.prototype) {
      return Consumer<AppStateManager>(
        builder: (context, appState, child) {
          return _buildContent(context, appState.shops);
        },
      );
    }

    // For production mode, use DataSourceBlocBuilder
    return DataSourceBlocBuilder<List<Shop>>(
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      bloc: bloc.listShopessBloc,
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

  Widget _buildContent(BuildContext context, List<Shop> shops) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة المطاعم والمحلات',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // الإحصائيات السريعة
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'إجمالي المحلات',
                      value: shops.length.toString(),
                      icon: Icons.store,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'المحلات النشطة',
                      value:
                          shops
                              .where((s) => s.isActive)
                              .length
                              .toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // جدول المحلات
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('اسم المحل')),
                        DataColumn(label: Text('المالك')),
                        DataColumn(label: Text('العنوان')),
                        DataColumn(label: Text('رقم الهاتف')),
                        DataColumn(label: Text('الطلبات النشطة')),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows:
                          shops.map((shop) {
                            // For active orders calculation, we'll use sample data
                            final activeOrders = SampleDataProvider.getOrdersByShopId(shop.shopId)
                                .where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled)
                                .length;

                            return DataRow(
                              cells: [
                                DataCell(Text(shop.shopName?? 'غير محدد')),
                                DataCell(Text(shop.userName)), // Shop owner same as shop name in this case
                                DataCell(Text(shop.address ?? 'غير محدد')),
                                DataCell(Text(shop.phone ?? 'غير محدد')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          activeOrders > 0
                                              ? Colors.orange.shade100
                                              : Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      activeOrders.toString(),
                                      style: TextStyle(
                                        color:
                                            activeOrders > 0
                                                ? Colors.orange.shade800
                                                : Colors.green.shade800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          shop.isActive
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      shop.isActive ? 'نشط' : 'غير نشط',
                                      style: TextStyle(
                                        color:
                                            shop.isActive
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
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
                                        onPressed:
                                            () => _showShopDetails(
                                              context,
                                              shop,
                                            ),
                                        tooltip: 'عرض التفاصيل',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.location_on),
                                        onPressed:
                                            () => _showShopLocation(
                                              context,
                                              shop,
                                            ),
                                        tooltip: 'عرض الموقع',
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

  void _showShopDetails(
    BuildContext context,
    shop,
  ) {
    final shopOrders = SampleDataProvider.getOrdersByShopId(shop.shopId);
    final completedOrders =
        shopOrders.where((o) => o.status == OrderStatus.delivered).length;
    final totalRevenue = shopOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalOrderPrice);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تفاصيل المحل: ${shop.userName}'),
            content: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('اسم المحل', shop.userName),
                  _buildDetailRow('المالك', shop.userName), // In enhanced model, owner same as shop name
                  _buildDetailRow('البريد الإلكتروني', shop.email),
                  _buildDetailRow('رقم الهاتف', shop.phone ?? 'غير محدد'),
                  _buildDetailRow('العنوان', shop.address ?? 'غير محدد'),
                  _buildDetailRow(
                    'الموقع',
                    shop.location != null 
                        ? '${shop.location!.latitude.toStringAsFixed(4)}, ${shop.location!.longitude.toStringAsFixed(4)}'
                        : 'غير محدد',
                  ),
                  _buildDetailRow('تاريخ التسجيل', shop.createdAt != null ? _formatDate(shop.createdAt!) : 'غير محدد'),
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

  void _showShopLocation(BuildContext context, shop) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('موقع المحل: ${shop.userName}'),
            content: SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  Text('العنوان: ${shop.address ?? 'غير محدد'}'),
                  const SizedBox(height: 8),
                  if (shop.location != null) ...[
                    Text(
                      'خط العرض: ${shop.location!.latitude.toStringAsFixed(6)}',
                    ),
                    Text(
                      'خط الطول: ${shop.location!.longitude.toStringAsFixed(6)}',
                    ),
                  ] else
                    const Text('الموقع غير محدد'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
