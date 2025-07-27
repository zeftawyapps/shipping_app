import 'package:flutter/material.dart';
import '../../../../logic/models/models.dart';
import '../../../../logic/data/sample_data.dart';
import 'orders_list_screen.dart';
import 'available_drivers_screen.dart';
import 'create_order_screen.dart';
import 'reports_screen.dart';
import '../../login_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  final Users user;

  const ShopHomeScreen({super.key, required this.user});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;
  Shop? shop;

  @override
  void initState() {
    super.initState();
    // البحث عن المحل بمعرف المالك
    final shops = SampleDataProvider.getShops();
    shop = shops.firstWhere(
      (s) => s.ownerId == widget.user.id,
      orElse: () => Shop(
        id: "unknown",
        ownerId: widget.user.id!,
        name: "محل غير محدد",
        address: "غير محدد",
        location: Location(latitude: 0, longitude: 0),
        phone: "غير محدد",
        email: "غير محدد",
        createdAt: DateTime.now(),
        isActive: false,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AppLoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (shop == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('خطأ'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'لم يتم العثور على بيانات المحل',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> screens = [
      OrdersListScreen(shopId: shop!.id),
      const AvailableDriversScreen(),
      CreateOrderScreen(shop: shop!),
      ReportsScreen(shopId: shop!.id),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(shop!.name),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'السائقين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'طلب جديد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'التقارير',
          ),
        ],
      ),
    );
  }
}
