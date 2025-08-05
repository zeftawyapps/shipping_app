# نظام الخريطة والمواقع - Shipping App

## نظرة عامة

تم تطوير نظام شامل للخريطة والمواقع في تطبيق الشحن والتوصيل، والذي يوفر واجهة موحدة لعرض وإدارة جميع النقاط الجغرافية في النظام بما في ذلك السائقين، المحلات، ونقاط الطلبات.

## المكونات الرئيسية

### 1. نموذج بيانات LocationPoint

**الملف:** `lib/logic/models/location_point.dart`

يوفر نموذج بيانات موحد لجميع النقاط الجغرافية في النظام:

```dart
class LocationPoint {
  String locationId;          // معرف فريد للنقطة
  String name;               // اسم النقطة
  String? description;       // وصف النقطة
  Location location;         // الإحداثيات الجغرافية
  LocationType type;         // نوع النقطة
  String? entityId;          // معرف الكيان المرتبط
  Map<String, dynamic>? metadata;  // بيانات إضافية
  DateTime lastUpdated;      // تاريخ آخر تحديث
  bool isActive;            // حالة النشاط
}
```

#### أنواع النقاط المدعومة:

- **driver**: نقاط السائقين
- **shop**: نقاط المحلات والمطاعم
- **order_pickup**: نقاط استلام الطلبات
- **order_delivery**: نقاط توصيل الطلبات

#### المصانع المخصصة:

```dart
// إنشاء نقطة للسائق
LocationPoint.fromDriver(
  driverId: "driver_001",
  driverName: "أحمد محمد",
  location: Location(latitude: 30.7936, longitude: 31.0003),
  phone: "+201234567890",
  status: "متاح",
  rating: 4.8,
);

// إنشاء نقطة للمحل
LocationPoint.fromShop(
  shopId: "shop_001",
  shopName: "مطعم الأكلات الشرقية",
  location: Location(latitude: 30.7936, longitude: 31.0003),
  address: "شارع النيل، مبنى 5",
  phone: "+20401234567",
  isActive: true,
);

// إنشاء نقطة استلام طلب
LocationPoint.fromOrderPickup(
  orderId: "order_001",
  shopName: "مطعم الأكلات الشرقية",
  location: Location(latitude: 30.7936, longitude: 31.0003),
  customerName: "عميل تجريبي",
  orderStatus: "في الطريق",
  totalPrice: 150.0,
);
```

### 2. واجهة الخريطة MapContentScreen

**الملف:** `lib/selutions/contral-panal/contents/map_content_screen.dart`

واجهة شاملة لعرض وإدارة جميع النقاط على الخريطة:

#### الميزات الرئيسية:

- **فلترة ديناميكية**: إمكانية فلترة النقاط حسب النوع (سائقين، محلات، طلبات)
- **إحصائيات فورية**: عرض إحصائيات مباشرة لكل نوع من النقاط
- **مفتاح الخريطة**: دليل مرئي للألوان والرموز المستخدمة
- **تفاصيل النقاط**: عرض تفاصيل شاملة عند النقر على أي نقطة
- **محاكي الخريطة**: واجهة مؤقتة حتى تفعيل Google Maps

#### مكونات الواجهة:

1. **قسم الفلاتر**:
   - تبديل عرض/إخفاء أنواع النقاط
   - فلتر محدد حسب النوع
   - زر تحديث البيانات

2. **قسم الإحصائيات**:
   - عدد السائقين
   - عدد المحلات
   - عدد الطلبات
   - عدد النقاط المعروضة

3. **منطقة الخريطة**:
   - عرض محاكي للخريطة
   - نقاط ملونة تمثل المواقع
   - إمكانية النقر للتفاصيل

4. **مفتاح الخريطة**:
   - دليل الألوان والرموز
   - قائمة النقاط النشطة
   - إمكانية التنقل المباشر

### 3. نظام الألوان والرموز

#### الألوان:
- **أزرق**: السائقين
- **أخضر**: المحلات
- **برتقالي**: نقاط استلام الطلبات
- **أحمر**: نقاط توصيل الطلبات

#### الرموز:
- **🚗**: السائقين (Icons.drive_eta)
- **🏪**: المحلات (Icons.store)
- **📦**: استلام الطلبات (Icons.call_received)
- **🚚**: توصيل الطلبات (Icons.call_made)

## التكامل مع النظام

### 1. إضافة الخريطة للتنقل

تمت إضافة الخريطة إلى نظام التنقل الرئيسي في `launch-cp.dart`:

```dart
RouteItem(
  icon: Icons.map_outlined,
  path: '/map',
  label: 'الخريطة',
  content: const MapContentScreen()
),
```

### 2. دمج البيانات

يستخدم النظام `SampleDataProvider` للحصول على البيانات:

```dart
// الحصول على جميع السائقين
final drivers = SampleDataProvider.getDrivers();

// الحصول على جميع المحلات
final shops = SampleDataProvider.getShops();

// الحصول على جميع الطلبات
final orders = SampleDataProvider.getOrders();
```

### 3. الفلترة والبحث

```dart
// فلترة النقاط حسب النوع
final driverPoints = allPoints.where(
  (point) => point.type == LocationType.driver
).toList();

// فلترة النقاط النشطة فقط
final activePoints = allPoints.where(
  (point) => point.isActive
).toList();
```

## أمثلة الاستخدام

### 1. إنشاء نقاط الموقع

```dart
// للسائق
final driverPoint = LocationPoint.fromDriver(
  driverId: driver.id!,
  driverName: driver.name ?? 'سائق غير محدد',
  location: driver.currentLocation!,
  phone: driver.phone,
  status: 'متاح',
  rating: driver.rating,
);

// للمحل
final shopPoint = LocationPoint.fromShop(
  shopId: shop.shopId,
  shopName: shop.userName,
  location: shop.location!,
  address: shop.address,
  phone: shop.phone,
  isActive: shop.isActive,
);
```

### 2. عرض التفاصيل

```dart
void showLocationDetails(LocationPoint point) {
  print('الاسم: ${point.name}');
  print('النوع: ${point.typeDisplayName}');
  print('الحالة: ${point.statusText}');
  if (point.phoneNumber != null) {
    print('الهاتف: ${point.phoneNumber}');
  }
  if (point.rating != null) {
    print('التقييم: ${point.rating}');
  }
}
```

### 3. الفلترة والتجميع

```dart
// تجميع النقاط حسب النوع
final groupedPoints = <LocationType, List<LocationPoint>>{};
for (final point in allPoints) {
  groupedPoints.putIfAbsent(point.type, () => []).add(point);
}

// احصائيات سريعة
final driverCount = groupedPoints[LocationType.driver]?.length ?? 0;
final shopCount = groupedPoints[LocationType.shop]?.length ?? 0;
```

## التطوير المستقبلي

### 1. تفعيل Google Maps
- دمج Google Maps API
- عرض الخريطة الحقيقية
- ميزات التنقل والاتجاهات

### 2. الميزات الإضافية
- تتبع المواقع المباشر
- إشعارات تغيير الموقع
- تجميع النقاط القريبة
- طبقات الخريطة المتقدمة

### 3. التحسينات
- أداء أفضل للبيانات الكبيرة
- فلاتر متقدمة أكثر
- تخصيص الألوان والرموز
- تصدير البيانات

## ملاحظات التطوير

### 1. هيكل الملفات
```
lib/
├── logic/
│   ├── models/
│   │   ├── location_point.dart     # نموذج نقطة الموقع
│   │   └── models.dart             # تصدير النماذج
│   └── data/
│       └── sample_data.dart        # بيانات تجريبية
├── selutions/contral-panal/contents/
│   ├── map_content_screen.dart     # واجهة الخريطة
│   └── launch-cp.dart              # تكوين التنقل
└── examples/
    └── location_point_example.dart # أمثلة الاستخدام
```

### 2. الاعتماديات
- Flutter Material Design
- Provider للإدارة الحالة
- نماذج البيانات الموجودة (Driver, Shop, Order)

### 3. الاختبار
يمكن اختبار النظام باستخدام الملف:
`lib/examples/location_point_example.dart`

---

تم تطوير هذا النظام بحيث يكون قابلاً للتوسع والصيانة، مع توفير واجهة موحدة وبسيطة لإدارة جميع المواقع في التطبيق.
