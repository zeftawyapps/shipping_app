// import 'package:flutter/material.dart';
// import 'package:shipping_app/logic/bloc/shopes_bloc.dart';
// import 'package:shipping_app/logic/models/location_point.dart';
//
// class LocationPointExample extends StatefulWidget {
//   const LocationPointExample({super.key});
//
//   @override
//   State<LocationPointExample> createState() => _LocationPointExampleState();
// }
//
// class _LocationPointExampleState extends State<LocationPointExample> {
//   final ShopesBloc _shopesBloc = ShopesBloc();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAllLocationPoints();
//   }
//
//   void _loadAllLocationPoints() {
//     _shopesBloc.loadAllLocationPoints();
//   }
//
//   void _addShopPoint() {
//     _shopesBloc.addShopPoint(
//       shopId: 'shop_123',
//       shopName: 'مطعم الحبايب',
//       latitude: 24.7136,
//       longitude: 46.6753,
//       address: 'شارع الملك فهد، الرياض',
//       phone: '+966112345678',
//       isActive: true,
//       additionalData: {
//         'category': 'مطعم',
//         'rating': 4.5,
//         'description': 'مطعم شعبي متميز',
//       },
//     );
//   }
//
//   void _addDriverPoint() {
//     _shopesBloc.addDriverPoint(
//       driverId: 'driver_456',
//       driverName: 'أحمد محمد',
//       latitude: 24.7000,
//       longitude: 46.6800,
//       phone: '+966501234567',
//       status: 'متاح',
//       rating: 4.8,
//       isActive: true,
//     );
//   }
//
//   void _addOrderPickupPoint() {
//     _shopesBloc.addOrderPickupPoint(
//       orderId: 'order_789',
//       shopName: 'مطعم الحبايب',
//       latitude: 24.7136,
//       longitude: 46.6753,
//       customerName: 'فاطمة أحمد',
//       orderStatus: 'قيد التحضير',
//       totalPrice: 85.50,
//       additionalData: {
//         'priority': 'عالية',
//         'estimatedTime': '30 دقيقة',
//       },
//     );
//   }
//
//   void _addOrderDeliveryPoint() {
//     _shopesBloc.addOrderDeliveryPoint(
//       orderId: 'order_789',
//       customerName: 'فاطمة أحمد',
//       latitude: 24.6800,
//       longitude: 46.7200,
//       address: 'حي العليا، الرياض',
//       phone: '+966501111111',
//       orderStatus: 'في الطريق',
//       totalPrice: 85.50,
//       additionalData: {
//         'priority': 'عالية',
//         'estimatedTime': '15 دقيقة',
//       },
//     );
//   }
//
//   void _updateDriverLocation() {
//     _shopesBloc.updateDriverLocation(
//       'driver_456',
//       24.7100, // latitude جديدة
//       46.6850, // longitude جديدة
//     );
//   }
//
//   void _updateShopLocation() {
//     _shopesBloc.updateShopLocation(
//       'shop_123',
//       24.7200, // latitude جديدة
//       46.6750, // longitude جديدة
//     );
//   }
//
//   void _loadShopPoints() {
//     _shopesBloc.loadLocationPointsByType(LocationType.shop);
//   }
//
//   void _loadDriverPoints() {
//     _shopesBloc.loadLocationPointsByType(LocationType.driver);
//   }
//
//   void _loadOrderPoints() {
//     _shopesBloc.loadLocationPointsByType(LocationType.order_pickup);
//   }
//
//   void _loadActivePointsOnly() {
//     _shopesBloc.loadActiveLocationPoints();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('أمثلة نقاط الموقع'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'إدارة نقاط الموقع',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//
//             // Add Points Section
//             const Text(
//               'إضافة نقاط جديدة:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _addShopPoint,
//                     icon: const Icon(Icons.store),
//                     label: const Text('إضافة محل'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _addDriverPoint,
//                     icon: const Icon(Icons.drive_eta),
//                     label: const Text('إضافة سائق'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _addOrderPickupPoint,
//                     icon: const Icon(Icons.call_received),
//                     label: const Text('استلام طلب'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _addOrderDeliveryPoint,
//                     icon: const Icon(Icons.call_made),
//                     label: const Text('توصيل طلب'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Update Location Section
//             const Text(
//               'تحديث المواقع:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _updateDriverLocation,
//                     icon: const Icon(Icons.location_on),
//                     label: const Text('تحديث موقع السائق'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _updateShopLocation,
//                     icon: const Icon(Icons.edit_location),
//                     label: const Text('تحديث موقع المحل'),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Load Points Section
//             const Text(
//               'عرض النقاط:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _loadAllLocationPoints,
//                     icon: const Icon(Icons.list),
//                     label: const Text('جميع النقاط'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _loadActivePointsOnly,
//                     icon: const Icon(Icons.visibility),
//                     label: const Text('النشطة فقط'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _loadShopPoints,
//                     icon: const Icon(Icons.store),
//                     label: const Text('المحلات'),
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _loadDriverPoints,
//                     icon: const Icon(Icons.drive_eta),
//                     label: const Text('السائقين'),
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: _loadOrderPoints,
//                     icon: const Icon(Icons.local_shipping),
//                     label: const Text('الطلبات'),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Location Points List
//             Expanded(
//               child: StreamBuilder<List<LocationPoint>>(
//                 stream: _shopesBloc.listLocationPointsBloc.stream,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text(
//                         'خطأ: ${snapshot.error}',
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     );
//                   }
//
//                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(
//                       child: Text(
//                         'لا توجد نقاط موقع',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     );
//                   }
//
//                   final locationPoints = snapshot.data!;
//
//                   return ListView.builder(
//                     itemCount: locationPoints.length,
//                     itemBuilder: (context, index) {
//                       final point = locationPoints[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 4),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: _getTypeColor(point.type),
//                             child: Icon(
//                               _getTypeIcon(point.type),
//                               color: Colors.white,
//                             ),
//                           ),
//                           title: Text(point.name),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(point.typeDisplayName),
//                               Text(
//                                 'الموقع: ${point.location.latitude.toStringAsFixed(4)}, ${point.location.longitude.toStringAsFixed(4)}',
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                               if (point.phoneNumber != null)
//                                 Text('الهاتف: ${point.phoneNumber}'),
//                             ],
//                           ),
//                           trailing: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 point.isActive ? Icons.check_circle : Icons.cancel,
//                                 color: point.isActive ? Colors.green : Colors.red,
//                               ),
//                               Text(
//                                 point.isActive ? 'نشط' : 'غير نشط',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: point.isActive ? Colors.green : Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           onTap: () {
//                             // Toggle active status
//                             _shopesBloc.toggleLocationPointActiveStatus(point.locationId);
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color _getTypeColor(LocationType type) {
//     switch (type) {
//       case LocationType.driver:
//         return Colors.blue;
//       case LocationType.shop:
//         return Colors.green;
//       case LocationType.order_pickup:
//         return Colors.orange;
//       case LocationType.order_delivery:
//         return Colors.red;
//     }
//   }
//
//   IconData _getTypeIcon(LocationType type) {
//     switch (type) {
//       case LocationType.driver:
//         return Icons.drive_eta;
//       case LocationType.shop:
//         return Icons.store;
//       case LocationType.order_pickup:
//         return Icons.call_received;
//       case LocationType.order_delivery:
//         return Icons.call_made;
//     }
//   }
// }
