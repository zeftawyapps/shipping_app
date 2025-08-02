import 'package:JoDija_tamplites/util/widgits/data_source_bloc_widgets/data_source_bloc_builder.dart';
import 'package:flutter/material.dart';
import 'package:shipping_app/logic/bloc/shopes_bloc.dart';
import 'package:shipping_app/selutions/moble-app/shops/dialog/shop_edit_details_dialog.dart';
import 'package:shipping_app/selutions/moble-app/shops/screens/login_screen.dart';
import '../../../../logic/data/user-data-loaded.dart';
import '../../../../logic/models/models.dart';
import 'orders_list_screen.dart';
import 'available_drivers_screen.dart';
import 'create_order_screen.dart';
import 'reports_screen.dart';

class ShopHomeScreen extends StatefulWidget {
  final Users user;

  const ShopHomeScreen({super.key, required this.user});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  int _selectedIndex = 0;
  Shop? shop;
  ShopesBloc shopesBloc = ShopesBloc();

  @override
  void initState() {
    UserDataLoaded().setUser(widget.user);
    super.initState();


    shopesBloc.loadShopById(widget.user.shopId!);
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
                    builder: (context) => const ShopLoginScreen(),
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

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.blue[50],
      selectedIconTheme: IconThemeData(color: Colors.blue[600]),
      selectedLabelTextStyle: TextStyle(
        color: Colors.blue[600],
        fontWeight: FontWeight.bold,
      ),
      unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
      unselectedLabelTextStyle: TextStyle(color: Colors.grey[600]),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.list_alt),
          label: Text('الطلبات'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.delivery_dining),
          label: Text('السائقين'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.add_box),
          label: Text('طلب جديد'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assessment),
          label: Text('التقارير'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DataSourceBlocBuilder(
      bloc: shopesBloc.shopesBloc,
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },

      success: (data) {
        shop = data;
        final List<Widget> screens = [
          OrdersListScreen(shopId: shop!.shopId),
          const AvailableDriversScreen(),
          CreateOrderScreen(shop: shop!),
          ReportsScreen(shopId: shop!.shopId),
        ];

        // Check if screen width is web size (typically > 760px)
        bool isWebSize = MediaQuery.of(context).size.width > 760;
       if (shop!.shopName == null || shop!.address == null || shop!.email.isEmpty) {
return Scaffold(
          appBar: AppBar(title: const Text('خطأ')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'لم يتم العثور على بيانات المحل',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Check screen size to determine dialog type
                    bool isSmallScreen = MediaQuery.of(context).size.width <= 760;
                    
                    if (isSmallScreen) {
                      // Show bottom sheet for small screens
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: ShopProfileDialog(shop: shop!),
                        ),
                      );
                    } else {
                      // Show dialog for larger screens
                      showDialog(
                        context: context,
                        builder: (context) => ShopProfileDialog(shop: shop!),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    ' تعديل البيانات  ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
       }






        return Scaffold(
          appBar: AppBar(
            title: Text(shop!.userName),
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
          body: isWebSize
              ? Row(
                  children: [
                    _buildNavigationRail(),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: screens[_selectedIndex]),
                  ],
                )
              : screens[_selectedIndex],
          bottomNavigationBar: isWebSize
              ? null
              : BottomNavigationBar(
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
      },
      failure: (error, retry) {
        return Scaffold(
          appBar: AppBar(title: const Text('خطأ')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'لم يتم العثور على بيانات المحل',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Check screen size to determine dialog type
                    bool isSmallScreen = MediaQuery.of(context).size.width <= 600;
                    
                    if (isSmallScreen) {
                      // Show bottom sheet for small screens
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: ShopProfileDialog(shop: shop!),
                        ),
                      );
                    } else {
                      // Show dialog for larger screens
                      showDialog(
                        context: context,
                        builder: (context) => ShopProfileDialog(shop: shop!),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    ' تعديل البيانات  ' , 
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
