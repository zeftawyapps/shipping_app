import 'package:JoDija_reposatory/jodija.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/laaunser.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/app_bar_config.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/route_item.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/models/sidebar_header_config.dart';
import 'package:JoDija_tamplites/tampletes/screens/routed_contral_panal/utiles/routes.dart';
 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipping_app/selutions/contral-panal/contents/orders_management_screen.dart';
import 'package:shipping_app/selutions/contral-panal/contents/shops_management_screen.dart';
import 'package:shipping_app/selutions/contral-panal/contents/users_management_screen.dart';
import 'package:shipping_app/selutions/contral-panal/contents/map_content_screen.dart';
import 'package:url_strategy/url_strategy.dart';

import '../../constants/views/assets.dart';
import '../../logic/provider/app_state_manager.dart';
import 'contents/dashboard.dart';
import 'contents/drivers_management_screen.dart';
import 'login_screen.dart';
import 'orders.dart';
class Launchcp extends StatefulWidget {
  const Launchcp({super.key});

  @override
  State<Launchcp> createState() => _LaunchcpState();
}

class _LaunchcpState extends State<Launchcp> {
  @override
  Widget build(BuildContext context) {


 return MultiProvider(providers:
 [
    ChangeNotifierProvider(
      create: (context) => AppStateManager(),
    ),

 ] ,

 //   'المدير: ahmed.admin@example.com\nكلمة المرور: password_admin_1',
   //
 child: SidebarNavigationControlPanale(
   initRouter: '/login',
    // routes: [
    //   SideBareRouters(
    //  path: '/login',
    //
    //     builder: (context, state) {
    //
    //    return   LoginScreen();
    //     },
    //   ),]

   showAppBarOnLargeScreen: true,
   isSidebarInCulomn: false ,
   itemWidth: 50 ,
   largeScreenAppBar: AppBarConfig(

     title: 'لوحة التحكم',
     bottom: const PreferredSize(
       preferredSize: Size.fromHeight(5.0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.end,
         children: [
           Text('مرحبا بكم في لوحة التحكم', style: TextStyle(fontSize: 15)),
         ],
       ),
     ),
     backgroundColor: Colors.blue,
     foregroundColor: Colors.white,

     elevation: 15.0,
     toolbarHeight: 60.0,
     centerTitle: true,
   ),
   sidebarHeader: SidebarHeaderConfig(
     title: 'تطبيقي',
     backgroundColor: Colors.blue,
     logoAssetPath: AppAsset.imglogo,
     height: 100,
   ),
   sidebarItems: [
     RouteItem(
       icon: Icons.dashboard_outlined,
       path: '/login',
       label: 'الرئيسية',
       content: const LoginScreen(),
        isSideBarRouted: false ,
     ),


     RouteItem(
       icon: Icons.dashboard_outlined,
       path: '/home',
       label: 'الرئيسية',
       content: const DashboardHomeScreen(),
     ),
     RouteItem(
         icon: Icons.people_outlined,
         path: '/users',
         label: 'المستخدمين',
         content: const  UsersManagementScreen()
     ),

     RouteItem(
         icon: Icons.shopping_bag_outlined,
         path: '/orders',
         label: 'الطلبات',
         content: const  OrdersManagementScreen()
     ),

     RouteItem(
       icon: Icons.store_outlined,
     path: '/restaurants',
        label: 'المطاعم',
        content: const  ShopsManagementScreen()),

     RouteItem(
         icon: Icons.local_shipping_outlined,
         path: '/drivers',
         label: 'السائقين',
         content: const  DriversManagementScreen()),

     RouteItem(
         icon: Icons.map_outlined,
         path: '/map',
         label: 'الخريطة',
         content: const MapContentScreen()),
   ],
 )
    ,
 );



  }
}
