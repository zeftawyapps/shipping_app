import 'package:shipping_app/logic/models/models.dart';


// بيانات تجريبية للمستخدمين
final List<Users> sampleUsers = [
  Users(
    UId: "user_admin_001",
    name: "أحمد المدير",
    email: "ahmed.admin@example.com",
    phone: "+201001234567",
    passwordHash: "hashed_password_admin_1",
    role: UserRole.admin,
    createdAt: DateTime.parse("2025-07-08T10:00:00Z"),
    isActive: true,
    isFirstTimeLogin: false, // Admin doesn't need first-time password change
  ),
  Users(
    UId: "user_driver_001",
    name: "محمد السائق",
    email: "mohamed.driver@example.com",
    phone: "+201117654321",
    passwordHash: "hashed_password_driver_1",
    role: UserRole.driver,
    createdAt: DateTime.parse("2025-07-08T10:05:00Z"),
    isActive: true,
    isFirstTimeLogin: true, // Driver needs first-time password change
  ),
  Users(
    UId: "user_driver_002",
    name: "علي السائق الثاني",
    email: "ali.driver@example.com",
    phone: "+201198765432",
    passwordHash: "hashed_password_driver_2",
    role: UserRole.driver,
    createdAt: DateTime.parse("2025-07-08T10:06:00Z"),
    isActive: true,
    isFirstTimeLogin: true, // Driver needs first-time password change
  ),
  Users(
    UId: "user_shop_001",
    name: "فاطمة صاحبة المطعم",
    email: "fatma.restaurant@example.com",
    phone: "+201229876543",
    passwordHash: "hashed_password_shop_1",
    role: UserRole.shop_owner,
    createdAt: DateTime.parse("2025-07-08T10:10:00Z"),
    isActive: true,
    isFirstTimeLogin: true, // Shop owner needs to change password on first login
  ),
  Users(
    UId: "user_shop_002",
    name: "خالد صاحب المخبز",
    email: "khaled.bakery@example.com",
    phone: "+201334455667",
    passwordHash: "hashed_password_shop_2",
    role: UserRole.shop_owner,
    createdAt: DateTime.parse("2025-07-08T10:12:00Z"),
    isActive: true,
    isFirstTimeLogin: true, // Shop owner needs to change password on first login
  ),
];

// بيانات تجريبية للمحلات
final List<Shop> sampleShops = [
  Shop(
    shopId: "shop_001",
    userName: "مطعم الأكلات الشرقية",
    address: "شارع النيل، مبنى 5، الطنطا",
    location: Location(latitude: 30.7936, longitude: 31.0003),
    phone: "+20401234567",
    email: "eastern.food@example.com",
    createdAt: DateTime.parse("2025-07-08T10:15:00Z"),
    isActive: true,
  ),
  Shop(
    shopId: "shop_002",
    userName: "مخبز الحلويات",
    address: "شارع طلعت حرب، الطنطا",
    location: Location(latitude: 30.8000, longitude: 30.9950),
    phone: "+20409876543",
    email: "sweets.bakery@example.com",
    createdAt: DateTime.parse("2025-07-08T10:20:00Z"),
    isActive: true,
  ),
];

// بيانات تجريبية للسائقين
final List<Driver> sampleDrivers = [
  Driver(
    id: "user_driver_001",
    currentLocation: Location(latitude: 30.7950, longitude: 31.0010),
    status: DriverStatus.available,
    rallyPoint: Location(latitude: 30.7955, longitude: 31.0020),
    lastLocationUpdate: DateTime.parse("2025-07-08T10:30:00Z"),
    rating: 4.8,
  ),
  Driver(
    id : "user_driver_002",
    currentLocation: Location(latitude: 30.8100, longitude: 30.9900),
    status: DriverStatus.busy,
    rallyPoint: null,
    lastLocationUpdate: DateTime.parse("2025-07-08T10:35:00Z"),
    rating: 4.5,
  ),
];

// بيانات تجريبية للطلبات
final List<Order> sampleOrders = [
  Order(
    shopId: "order_001",

    driverId: "user_driver_001",
    senderDetails: ContactDetails(
      name: "مطعم الأكلات الشرقية",
      phone: "+20401234567",
      address: "الرياض، المملكة العربية السعودية - حي الملز، شارع الأمير سلطان",
      location: Location(latitude: 30.7936, longitude: 31.0003),
    ),
    recipientDetails: ContactDetails(
      name: "عميل تجريبي 1",
      phone: "+201009988776",
      email: "customer1@example.com",
      address: "الرياض، المملكة العربية السعودية - حي النخيل، شارع الملك فهد، مبنى رقم 123",
      location: Location(latitude: 30.7900, longitude: 31.0050),
    ),
    items: [
      OrderItem(
        productId: "prod_food_001",
        name: "وجبة دجاج مشوي",
        quantity: 1,
        unitPrice: 100.00,
      ),
      OrderItem(
        productId: "prod_food_002",
        name: "طبق أرز",
        quantity: 2,
        unitPrice: 20.00,
      ),
      OrderItem(
        productId: "prod_food_003",
        name: "سلطة خضراء",
        quantity: 1,
        unitPrice: 10.00,
      ),
    ],
    totalOrderPrice: 150.00,
    status: OrderStatus.on_the_way,
    createdAt: DateTime.parse("2025-07-08T11:00:00Z"),
    acceptedAt: DateTime.parse("2025-07-08T11:05:00Z"),
    pickedUpAt: DateTime.parse("2025-07-08T11:20:00Z"),
    deliveredAt: null,
    cancelledAt: null,
    cancellationReason: null, id: '',
  ),
  Order(
    shopId: "order_002",
  id : "order_002",
    driverId: null,
    senderDetails: ContactDetails(
      name: "مخبز الحلويات",
      phone: "+20409876543",
      address: "الرياض، المملكة العربية السعودية - حي الورود، شارع العليا",
      location: Location(latitude: 30.8000, longitude: 30.9950),
    ),
    recipientDetails: ContactDetails(
      name: "عميل تجريبي 2",
      phone: "+201115544332",
      email: null,
      address: "الرياض، المملكة العربية السعودية - حي الصحافة، شارع التحلية، برج الأعمال",
      location: Location(latitude: 30.8050, longitude: 30.9880),
    ),
    items: [
      OrderItem(
        productId: "prod_sweet_001",
        name: "علبة حلويات مشكلة (كبيرة)",
        quantity: 1,
        unitPrice: 120.50,
      ),
    ],
    totalOrderPrice: 120.50,
    status: OrderStatus.pending_acceptance,
    createdAt: DateTime.parse("2025-07-08T11:30:00Z"),
    acceptedAt: null,
    pickedUpAt: null,
    deliveredAt: null,
    cancelledAt: null,
    cancellationReason: null,
  ),
  Order(
    shopId: "order_003",
 id: "order_003",
    driverId: "user_driver_002",
    senderDetails: ContactDetails(
      name: "مطعم الأكلات الشرقية",
      phone: "+20401234567",
      address: "الرياض، المملكة العربية السعودية - حي الملز، شارع الأمير سلطان",
      location: Location(latitude: 30.7936, longitude: 31.0003),
    ),
    recipientDetails: ContactDetails(
      name: "عميل تجريبي 3",
      phone: "+201223344556",
      email: "customer3@example.com",
      address: "الرياض، المملكة العربية السعودية - حي المروج، شارع الأمير محمد بن عبدالعزيز",
      location: Location(latitude: 30.7800, longitude: 31.0100),
    ),
    items: [
      OrderItem(
        productId: "prod_food_004",
        name: "وجبة سمك مقلي",
        quantity: 1,
        unitPrice: 120.00,
      ),
      OrderItem(
        productId: "prod_food_005",
        name: "مشروب غازي",
        quantity: 2,
        unitPrice: 8.00,
      ),
    ],
    totalOrderPrice: 136.00,
    status: OrderStatus.delivered,
    createdAt: DateTime.parse("2025-07-08T09:00:00Z"),
    acceptedAt: DateTime.parse("2025-07-08T09:05:00Z"),
    pickedUpAt: DateTime.parse("2025-07-08T09:25:00Z"),
    deliveredAt: DateTime.parse("2025-07-08T09:50:00Z"),
    cancelledAt: null,
    cancellationReason: null,
  ),
  Order(
    shopId: "order_004",
    id: "order_004",
    driverId: null,
    senderDetails: ContactDetails(
      name: "مخبز الحلويات",
      phone: "+20409876543",
      location: Location(latitude: 30.8000, longitude: 30.9950),
    ),
    recipientDetails: ContactDetails(
      name: "عميل تجريبي 4",
      phone: "+201667788990",
      email: "customer4@example.com",
      location: Location(latitude: 30.8200, longitude: 30.9800),
    ),
    items: [
      OrderItem(
        productId: "prod_sweet_002",
        name: "كيك شوكولاتة",
        quantity: 1,
        unitPrice: 85.00,
      ),
    ],
    totalOrderPrice: 85.00,
    status: OrderStatus.cancelled,
    createdAt: DateTime.parse("2025-07-08T08:00:00Z"),
    acceptedAt: null,
    pickedUpAt: null,
    deliveredAt: null,
    cancelledAt: DateTime.parse("2025-07-08T08:15:00Z"),
    cancellationReason: "العميل ألغى الطلب",
  ),
];

// متفائل للقيم الثابتة
class SampleDataProvider {
  static const String googleMapsApiKey =
      "AIzaSyD2duRi55YWuhTmCqH8gFEV7gGDhoYsJUQ";

  static List<Users> getUsers() => List.from(sampleUsers);
  static List<Shop> getShops() => List.from(sampleShops);
  static List<Driver> getDrivers() => List.from(sampleDrivers);
  static List<Order> getOrders() => List.from(sampleOrders);

  // دالة للحصول على إحصائيات الطلبات
  static OrderStatistics getOrderStatistics() {
    final orders = getOrders();
    final totalOrders = orders.length;
    final completedOrders =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders =
        orders.where((o) => o.status == OrderStatus.cancelled).length;
    final activeOrders =
        orders
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

  // دالة للحصول على إحصائيات السائقين
  static DriverStatistics getDriverStatistics() {
    final drivers = getDrivers();
    final totalDrivers = drivers.length;
    final availableDrivers =
        drivers.where((d) => d.status == DriverStatus.available).length;
    final busyDrivers =
        drivers.where((d) => d.status == DriverStatus.busy).length;
    final atRallyPointDrivers =
        drivers.where((d) => d.status == DriverStatus.at_rally_point).length;

    return DriverStatistics(
      totalDrivers: totalDrivers,
      availableDrivers: availableDrivers,
      busyDrivers: busyDrivers,
      atRallyPointDrivers: atRallyPointDrivers,
    );
  }

  // دالة للبحث عن مستخدم بالإيميل وكلمة المرور
  static Users? authenticateUser(String email, String password) {
    try {
      return sampleUsers.firstWhere(
        (user) =>
            user.email == email &&
            user.passwordHash == "hashed_$password" &&
            user.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  // دالة للحصول على مستخدم بالمعرف
  static Users? getUserById(String id) {
    try {
      return sampleUsers.firstWhere((user) => user.UId == id);
    } catch (e) {
      return null;
    }
  }

  // دالة للحصول على محل بالمعرف
  static Shop? getShopById(String id) {
    try {
      return sampleShops.firstWhere((shop) => shop.shopId == id);
    } catch (e) {
      return null;
    }
  }

  // دالة للحصول على سائق بالمعرف
  static Driver? getDriverById(String id) {
    try {
      return sampleDrivers.firstWhere((driver) => driver.id  == id);
    } catch (e) {
      return null;
    }
  }

  // دالة للحصول على السائقين المتاحين
  static List<Driver> getAvailableDrivers() {
    return sampleDrivers
        .where((driver) => driver.status == DriverStatus.available)
        .toList();
  }

  // دالة للحصول على طلبات محل معين
  static List<Order> getOrdersByShopId(String shopId) {
    return sampleOrders.where((order) => order.shopId == shopId).toList();
  }

  // دالة للحصول على طلبات سائق معين
  static List<Order> getOrdersByDriverId(String driverId) {
    return sampleOrders.where((order) => order.driverId == driverId).toList();
  }
}
