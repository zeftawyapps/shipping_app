// نماذج بيانات الإحصائيات

class OrderStatistics {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int activeOrders;
  final double completionRate;
  final double cancellationRate;

  OrderStatistics({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.activeOrders,
    required this.completionRate,
    required this.cancellationRate,
  });
}

class DriverStatistics {
  final int totalDrivers;
  final int availableDrivers;
  final int busyDrivers;
  final int atRallyPointDrivers;

  DriverStatistics({
    required this.totalDrivers,
    required this.availableDrivers,
    required this.busyDrivers,
    required this.atRallyPointDrivers,
  });
}
