
import 'package:JoDija_reposatory/jodija.dart';
import 'package:JoDija_tamplites/util/localization/loaclized_init.dart';
import 'package:JoDija_tamplites/util/navigations/animation_types.dart';
import 'package:JoDija_tamplites/util/navigations/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'app-configs.dart';
import 'constants/views/themes.dart';

class AppLouncher extends StatelessWidget {
  const AppLouncher({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    NavigationService ns = NavigationService();
    ns.animationType= AnimationType.slide;
// JoDijaTestConnection().test();
    return ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        designSize: const Size(375, 812),
        builder: (context ,  Widget? child) {

          return MaterialApp(
            debugShowCheckedModeBanner: false ,
            navigatorKey: ns . navigatorKey,
            onGenerateRoute: ns.generateRoute ,
            // supportedLocales: AppLocalizationsInit().supportedLocales,
            // locale: AppLocalizationsInit().local,
            // localizationsDelegates:
            // AppLocalizationsInit().localizationsDelegates,
            theme:  Themes(context).lightTheme() ,
            darkTheme: Themes(context).darkTheme,
            themeMode: ThemeMode.light,
            home: AppConfigration.launchScreen(),

          );


        }
    );
  }
}
