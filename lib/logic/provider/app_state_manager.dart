import 'package:flutter/foundation.dart';
import '../models/data_models.dart';
import '../data/sample_data.dart';

class AppStateManager extends ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  List<Shop> _shops = [];
  List<Driver> _drivers = [];
  List<Order> _orders = [];

  // Getters
  User? get currentUser => _currentUser;
  List<User> get users => _users;
  List<Shop> get shops => _shops;
  List<Driver> get drivers => _drivers;
  List<Order> get orders => _orders;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // Constructor
  AppStateManager() {
    _loadSampleData();
  }

  // تحميل البيانات التجريبية
  void _loadSampleData() {
    _users = SampleDataProvider.getUsers();
    _shops = SampleDataProvider.getShops();
    _drivers = SampleDataProvider.getDrivers();
    _orders = SampleDataProvider.getOrders();
  }

  // تسجيل الدخول
  bool login(String email, String password) {
    final user = SampleDataProvider.authenticateUser(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  // تسجيل الخروج
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // إدارة المستخدمين
  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  // إدارة المحلات
  void addShop(Shop shop) {
    _shops.add(shop);
    notifyListeners();
  }

  void updateShop(Shop updatedShop) {
    final index = _shops.indexWhere((shop) => shop.id == updatedShop.id);
    if (index != -1) {
      _shops[index] = updatedShop;
      notifyListeners();
    }
  }

  void deleteShop(String shopId) {
    _shops.removeWhere((shop) => shop.id == shopId);
    notifyListeners();
  }

  // إدارة السائقين
  void updateDriverLocation(String driverId, Location location) {
    final index = _drivers.indexWhere((driver) => driver.id == driverId);
    if (index != -1) {
      _drivers[index] = Driver(
        id: _drivers[index].id,
        currentLocation: location,
        status: _drivers[index].status,
        rallyPoint: _drivers[index].rallyPoint,
        lastLocationUpdate: DateTime.now(),
        rating: _drivers[index].rating,
      );
      notifyListeners();
    }
  }

  void updateDriverStatus(String driverId, DriverStatus status) {
    final index = _drivers.indexWhere((driver) => driver.id == driverId);
    if (index != -1) {
      _drivers[index] = Driver(
        id: _drivers[index].id,
        currentLocation: _drivers[index].currentLocation,
        status: status,
        rallyPoint: _drivers[index].rallyPoint,
        lastLocationUpdate: DateTime.now(),
        rating: _drivers[index].rating,
      );
      notifyListeners();
    }
  }

  // إدارة الطلبات
  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  void deleteOrder(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
    notifyListeners();
  }

  // تعيين سائق لطلب
  void assignDriverToOrder(String orderId, String driverId) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];
      final updatedOrder = Order(
        id: order.id,
        shopId: order.shopId,
        driverId: driverId,
        senderDetails: order.senderDetails,
        recipientDetails: order.recipientDetails,
        items: order.items,
        totalOrderPrice: order.totalOrderPrice,
        status: OrderStatus.accepted,
        createdAt: order.createdAt,
        acceptedAt: DateTime.now(),
        pickedUpAt: order.pickedUpAt,
        deliveredAt: order.deliveredAt,
        cancelledAt: order.cancelledAt,
        cancellationReason: order.cancellationReason,
      );
      _orders[orderIndex] = updatedOrder;

      // تحديث حالة السائق إلى مشغول
      updateDriverStatus(driverId, DriverStatus.busy);
      notifyListeners();
    }
  }

  // تحديث حالة الطلب
  void updateOrderStatus(String orderId, OrderStatus status) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = _orders[orderIndex];
      DateTime? pickedUpAt = order.pickedUpAt;
      DateTime? deliveredAt = order.deliveredAt;
      DateTime? cancelledAt = order.cancelledAt;

      switch (status) {
        case OrderStatus.picked_up:
          pickedUpAt = DateTime.now();
          break;
        case OrderStatus.delivered:
          deliveredAt = DateTime.now();
          // تحديث حالة السائق إلى متاح
          if (order.driverId != null) {
            updateDriverStatus(order.driverId!, DriverStatus.available);
          }
          break;
        case OrderStatus.cancelled:
          cancelledAt = DateTime.now();
          // تحديث حالة السائق إلى متاح
          if (order.driverId != null) {
            updateDriverStatus(order.driverId!, DriverStatus.available);
          }
          break;
        default:
          break;
      }

      final updatedOrder = Order(
        id: order.id,
        shopId: order.shopId,
        driverId: order.driverId,
        senderDetails: order.senderDetails,
        recipientDetails: order.recipientDetails,
        items: order.items,
        totalOrderPrice: order.totalOrderPrice,
        status: status,
        createdAt: order.createdAt,
        acceptedAt: order.acceptedAt,
        pickedUpAt: pickedUpAt,
        deliveredAt: deliveredAt,
        cancelledAt: cancelledAt,
        cancellationReason: order.cancellationReason,
      );
      _orders[orderIndex] = updatedOrder;
      notifyListeners();
    }
  }

  // البحث والتصفية
  List<Order> getFilteredOrders({
    OrderStatus? status,
    String? shopId,
    String? driverId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _orders.where((order) {
      bool matchesStatus = status == null || order.status == status;
      bool matchesShop = shopId == null || order.shopId == shopId;
      bool matchesDriver = driverId == null || order.driverId == driverId;
      bool matchesDate = true;

      if (startDate != null) {
        matchesDate = order.createdAt.isAfter(startDate);
      }
      if (endDate != null) {
        matchesDate = matchesDate && order.createdAt.isBefore(endDate);
      }

      return matchesStatus && matchesShop && matchesDriver && matchesDate;
    }).toList();
  }

  List<User> getFilteredUsers({UserRole? role, String? searchQuery}) {
    return _users.where((user) {
      bool matchesRole = role == null || user.role == role;
      bool matchesSearch =
          searchQuery == null ||
          user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.phone.contains(searchQuery);

      return matchesRole && matchesSearch;
    }).toList();
  }

  List<Driver> getFilteredDrivers({DriverStatus? status}) {
    return _drivers.where((driver) {
      bool matchesStatus = status == null || driver.status == status;
      return matchesStatus;
    }).toList();
  }

  // الحصول على الإحصائيات
  OrderStatistics getOrderStatistics() {
    final totalOrders = _orders.length;
    final completedOrders =
        _orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders =
        _orders.where((o) => o.status == OrderStatus.cancelled).length;
    final activeOrders =
        _orders
            .where(
              (o) =>
                  o.status != OrderStatus.delivered &&
                  o.status != OrderStatus.cancelled,
            )
            .length;

    return OrderStatistics(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      activeOrders: activeOrders,
      completionRate:
          totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0,
      cancellationRate:
          totalOrders > 0 ? (cancelledOrders / totalOrders) * 100 : 0,
    );
  }

  DriverStatistics getDriverStatistics() {
    final totalDrivers = _drivers.length;
    final availableDrivers =
        _drivers.where((d) => d.status == DriverStatus.available).length;
    final busyDrivers =
        _drivers.where((d) => d.status == DriverStatus.busy).length;
    final atRallyPointDrivers =
        _drivers.where((d) => d.status == DriverStatus.at_rally_point).length;

    return DriverStatistics(
      totalDrivers: totalDrivers,
      availableDrivers: availableDrivers,
      busyDrivers: busyDrivers,
      atRallyPointDrivers: atRallyPointDrivers,
    );
  }

  // دالة للحصول على اسم المستخدم
  String getUserName(String userId) {
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse:
          () => User(
            id: userId,
            name: "غير معروف",
            email: "",
            phone: "",
            passwordHash: "",
            role: UserRole.driver,
            createdAt: DateTime.now(),
            isActive: false,
          ),
    );
    return user.name;
  }

  // دالة للحصول على اسم المحل
  String getShopName(String shopId) {
    final shop = _shops.firstWhere(
      (s) => s.id == shopId,
      orElse:
          () => Shop(
            id: shopId,
            ownerId: "",
            name: "غير معروف",
            address: "",
            location: Location(latitude: 0, longitude: 0),
            phone: "",
            email: "",
            createdAt: DateTime.now(),
            isActive: false,
          ),
    );
    return shop.name;
  }
}
