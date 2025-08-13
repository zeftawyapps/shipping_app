
import 'package:JoDija_reposatory/https/http_urls.dart';
import 'package:JoDija_reposatory/utilis/json_reader/json_asset_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shipping_app/enums.dart';
import 'package:shipping_app/selutions/contral-panal/launch-cp.dart';
import 'package:shipping_app/selutions/moble-app/driver/driver_login_screen.dart';
import 'package:shipping_app/selutions/moble-app/shops/screens/login_screen.dart';
import 'constants/configs.dart';
abstract class AppConfigration {
  static AppType appType = AppType.DashBord;
  static EnvType envType = EnvType.dev;
  static BackendState backendState = BackendState.remote_dev;
  static initConfig(AppType appType, EnvType envType, BackendState backendState) {
    AppConfigration.appType = appType;
    AppConfigration.envType = envType;
    AppConfigration.backendState = backendState;
    
  }
  static Future FirebaseInit() async {



    try {
      var data =
      await JsonAssetReader(path: AppConfigAssets.firebaseConfig).data;
      var firebaseConfig = data['firebaseConfig'];
      if (envType == EnvType.prod) {
        var prod = firebaseConfig['prod'];
        await Firebase.initializeApp(
            options: FirebaseOptions(
                apiKey: prod['apiKey'],
                appId: prod['appId'],
                messagingSenderId: prod['messagingSenderId'],
                projectId: prod['projectId'],
                storageBucket: prod['storageBucket']));
      } else {
        var dev = firebaseConfig['dev'];
        await Firebase.initializeApp(
            options: FirebaseOptions(
                apiKey: dev['apiKey'],
                appId: dev['appId'],
                messagingSenderId: dev['messagingSenderId'],
                projectId: dev['projectId'],
                storageBucket: dev['storageBucket']));
      }


    } on Exception catch (e) {
      print(e);
    }
  }

  static Future backenRoutsdInit() async {
    var data = await JsonAssetReader(path: AppConfigAssets.BaseUrl).data;
    var baseUrls = data['baseUrls'];
    String BaseUrl;

    if (backendState == BackendState.local) {
      BaseUrl = baseUrls['local'];
    } else {
      BaseUrl = baseUrls['remote'];
    }
    HttpUrlsEnveiroment(baseUrl: BaseUrl);
  }

  static Widget _launchWidget({required Widget web, required Widget mobile}) {
    if (kIsWeb) {
      return web;
    } else {
      return mobile;
    }
  }

  // static Widget _launchWeb({required Widget web, required Widget dashboard}) {
  //   if (appType == AppType.App) {
  //     return web;
  //   } else {
  //     return dashboard;
  //   }
  // }

  static Widget launchScreen() {

    if ( AppConfigration.appType == AppType.App_driver ) {
      return
      DriverLoginScreen() ;

    } else {
      return ShopLoginScreen() ;

    }
  // or any other screen you want to launch
}
// static String baseRoute() {
//   if (!kIsWeb) {
//     if (appType == AppType.App) {
//       return LandingPageClasicMode.path;
//     } else {
//       return DashBoardSplashScreen.path;
//     }
//
//   } else {
//     if (appType == AppType.App) {
//       return LandingPageClasicMode.path;
//     } else {
//       return DashBoardSplashScreen.path;
//     }
//   }
// }

// static void setAppLocal (String localCode){
//     LocalizationConfig localizationConfig = LocalizationConfig(localizedValues: {
//       'ar': AppLocalizationsAr(),
//       'en': AppLocalizationsEn(),
//     });
//     localizationConfig.setLocale(Locale(localCode));
// Translation().getlocal();
// }
// }

}
