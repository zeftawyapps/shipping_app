import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/models/data_models.dart';
import '../../../logic/provider/app_state_manager.dart';

class ShopsManagementScreen extends StatelessWidget {
  const ShopsManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
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
                      value: appState.shops.length.toString(),
                      icon: Icons.store,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'المحلات النشطة',
                      value:
                          appState.shops
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
                          appState.shops.map((shop) {
                            final owner = appState.users.firstWhere(
                              (u) => u.id == shop.ownerId,
                            );
                            final activeOrders =
                                appState.orders
                                    .where(
                                      (o) =>
                                          o.shopId == shop.id &&
                                          o.status != OrderStatus.delivered &&
                                          o.status != OrderStatus.cancelled,
                                    )
                                    .length;

                            return DataRow(
                              cells: [
                                DataCell(Text(shop.name)),
                                DataCell(Text(owner.name)),
                                DataCell(Text(shop.address)),
                                DataCell(Text(shop.phone)),
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
                                              owner,
                                              appState,
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
      },
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
    owner,
    AppStateManager appState,
  ) {
    final shopOrders =
        appState.orders.where((o) => o.shopId == shop.id).toList();
    final completedOrders =
        shopOrders.where((o) => o.status == OrderStatus.delivered).length;
    final totalRevenue = shopOrders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalOrderPrice);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('تفاصيل المحل: ${shop.name}'),
            content: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('اسم المحل', shop.name),
                  _buildDetailRow('المالك', owner.name),
                  _buildDetailRow('البريد الإلكتروني', shop.email),
                  _buildDetailRow('رقم الهاتف', shop.phone),
                  _buildDetailRow('العنوان', shop.address),
                  _buildDetailRow(
                    'الموقع',
                    '${shop.location.latitude.toStringAsFixed(4)}, ${shop.location.longitude.toStringAsFixed(4)}',
                  ),
                  _buildDetailRow('تاريخ التسجيل', _formatDate(shop.createdAt)),
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
            title: Text('موقع المحل: ${shop.name}'),
            content: SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  Text('العنوان: ${shop.address}'),
                  const SizedBox(height: 8),
                  Text(
                    'خط العرض: ${shop.location.latitude.toStringAsFixed(6)}',
                  ),
                  Text(
                    'خط الطول: ${shop.location.longitude.toStringAsFixed(6)}',
                  ),
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
