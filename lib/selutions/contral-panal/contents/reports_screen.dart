import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../logic/models/data_models.dart';
import '../../../logic/provider/app_state_manager.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReport = 'overview';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (context, appState, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط التبويب
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'التقارير والإحصائيات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedReport,
                        items: const [
                          DropdownMenuItem(
                            value: 'overview',
                            child: Text('نظرة عامة'),
                          ),
                          DropdownMenuItem(
                            value: 'orders',
                            child: Text('تقرير الطلبات'),
                          ),
                          DropdownMenuItem(
                            value: 'drivers',
                            child: Text('تقرير السائقين'),
                          ),
                          DropdownMenuItem(
                            value: 'shops',
                            child: Text('تقرير المحلات'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedReport = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // محتوى التقرير
              Expanded(child: _buildReportContent(appState)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportContent(AppStateManager appState) {
    switch (_selectedReport) {
      case 'overview':
        return _buildOverviewReport(appState);
      case 'orders':
        return _buildOrdersReport(appState);
      case 'drivers':
        return _buildDriversReport(appState);
      case 'shops':
        return _buildShopsReport(appState);
      default:
        return _buildOverviewReport(appState);
    }
  }

  Widget _buildOverviewReport(AppStateManager appState) {
    final orderStats = appState.getOrderStatistics();
    final driverStats = appState.getDriverStatistics();

    return Column(
      children: [
        // الإحصائيات العامة
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي الطلبات',
                value: orderStats.totalOrders.toString(),
                icon: Icons.shopping_bag,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'معدل الإنجاز',
                value: '${orderStats.completionRate.toStringAsFixed(1)}%',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'معدل الإلغاء',
                value: '${orderStats.cancellationRate.toStringAsFixed(1)}%',
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'السائقين النشطين',
                value: driverStats.totalDrivers.toString(),
                icon: Icons.local_shipping,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // الرسوم البيانية
        Expanded(
          child: Row(
            children: [
              // رسم بياني للطلبات
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'توزيع الطلبات حسب الحالة',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: orderStats.completedOrders.toDouble(),
                                  title: 'مكتملة',
                                  color: Colors.green,
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  value: orderStats.activeOrders.toDouble(),
                                  title: 'نشطة',
                                  color: Colors.orange,
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  value: orderStats.cancelledOrders.toDouble(),
                                  title: 'ملغاة',
                                  color: Colors.red,
                                  radius: 50,
                                ),
                              ],
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // رسم بياني للسائقين
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'توزيع السائقين حسب الحالة',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY:
                                          driverStats.availableDrivers
                                              .toDouble(),
                                      color: Colors.green,
                                      width: 20,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: driverStats.busyDrivers.toDouble(),
                                      color: Colors.red,
                                      width: 20,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 2,
                                  barRods: [
                                    BarChartRodData(
                                      toY:
                                          driverStats.atRallyPointDrivers
                                              .toDouble(),
                                      color: Colors.blue,
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('متاح');
                                        case 1:
                                          return const Text('مشغول');
                                        case 2:
                                          return const Text('نقطة تجمع');
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersReport(AppStateManager appState) {
    final ordersByStatus = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      ordersByStatus[status] =
          appState.orders.where((o) => o.status == status).length;
    }

    final ordersByShop = <String, int>{};
    for (final shop in appState.shops) {
      ordersByShop[shop.name] =
          appState.orders.where((o) => o.shopId == shop.id).length;
    }

    return Column(
      children: [
        // إحصائيات الطلبات
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات الطلبات التفصيلية',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children:
                      OrderStatus.values.map((status) {
                        return Expanded(
                          child: Column(
                            children: [
                              Text(
                                ordersByStatus[status].toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getOrderStatusColor(status),
                                ),
                              ),
                              Text(
                                _getOrderStatusName(status),
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // توزيع الطلبات حسب المحل
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توزيع الطلبات حسب المحل',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ordersByShop.length,
                      itemBuilder: (context, index) {
                        final shopName = ordersByShop.keys.elementAt(index);
                        final orderCount = ordersByShop[shopName]!;
                        final percentage =
                            appState.orders.isNotEmpty
                                ? (orderCount / appState.orders.length) * 100
                                : 0.0;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade600,
                            child: Text(
                              orderCount.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(shopName),
                          trailing: Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriversReport(AppStateManager appState) {
    return Column(
      children: [
        // إحصائيات السائقين
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات السائقين',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            appState.drivers
                                .where(
                                  (d) => d.status == DriverStatus.available,
                                )
                                .length
                                .toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('متاح'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            appState.drivers
                                .where((d) => d.status == DriverStatus.busy)
                                .length
                                .toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const Text('مشغول'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            appState.drivers
                                .where(
                                  (d) =>
                                      d.status == DriverStatus.at_rally_point,
                                )
                                .length
                                .toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text('نقطة تجمع'),
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

        // قائمة السائقين مع الأداء
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أداء السائقين',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: appState.drivers.length,
                      itemBuilder: (context, index) {
                        final driver = appState.drivers[index];
                        final user = appState.users.firstWhere(
                          (u) => u.id == driver.id,
                        );
                        final driverOrders =
                            appState.orders
                                .where((o) => o.driverId == driver.id)
                                .toList();
                        final completedOrders =
                            driverOrders
                                .where((o) => o.status == OrderStatus.delivered)
                                .length;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getDriverStatusColor(
                              driver.status,
                            ),
                            child: Text(
                              completedOrders.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text(
                            'التقييم: ${driver.rating.toStringAsFixed(1)} | الحالة: ${_getDriverStatusName(driver.status)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${driverOrders.length} طلب',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (driverOrders.isNotEmpty)
                                Text(
                                  '${((completedOrders / driverOrders.length) * 100).toStringAsFixed(1)}% نجاح',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopsReport(AppStateManager appState) {
    return Column(
      children: [
        // إحصائيات المحلات
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات المحلات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            appState.shops.length.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const Text('إجمالي المحلات'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            appState.shops
                                .where((s) => s.isActive)
                                .length
                                .toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('محلات نشطة'),
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

        // أداء المحلات
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أداء المحلات',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: appState.shops.length,
                      itemBuilder: (context, index) {
                        final shop = appState.shops[index];
                        final shopOrders =
                            appState.orders
                                .where((o) => o.shopId == shop.id)
                                .toList();
                        final completedOrders =
                            shopOrders
                                .where((o) => o.status == OrderStatus.delivered)
                                .length;
                        final totalRevenue = shopOrders
                            .where((o) => o.status == OrderStatus.delivered)
                            .fold(
                              0.0,
                              (sum, order) => sum + order.totalOrderPrice,
                            );

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                shop.isActive ? Colors.green : Colors.red,
                            child: Text(
                              shopOrders.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(shop.name),
                          subtitle: Text(
                            'الطلبات المكتملة: $completedOrders | الإيرادات: ${totalRevenue.toStringAsFixed(2)} ج.م',
                          ),
                          trailing: Icon(
                            shop.isActive ? Icons.check_circle : Icons.cancel,
                            color: shop.isActive ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  Color _getOrderStatusColor(OrderStatus status) {
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

  String _getOrderStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending_acceptance:
        return 'في انتظار القبول';
      case OrderStatus.accepted:
        return 'مقبول';
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

  Color _getDriverStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return Colors.green;
      case DriverStatus.busy:
        return Colors.red;
      case DriverStatus.at_rally_point:
        return Colors.blue;
    }
  }

  String _getDriverStatusName(DriverStatus status) {
    switch (status) {
      case DriverStatus.available:
        return 'متاح';
      case DriverStatus.busy:
        return 'مشغول';
      case DriverStatus.at_rally_point:
        return 'في نقطة التجمع';
    }
  }
}
