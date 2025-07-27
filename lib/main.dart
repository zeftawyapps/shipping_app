import 'package:flutter/material.dart';
import 'package:shipping_app/app-configs.dart';
import 'package:shipping_app/enums.dart';
import 'package:shipping_app/selutions/contral-panal/launch-cp.dart';
import 'package:url_strategy/url_strategy.dart';

 
import 'launches.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  appInit();
  if (AppConfigration.appType == AppType.App_shop) {
    runApp(  AppLouncher());
  } else {
    setPathUrlStrategy(); // من مكتبة url_strategy
    runApp( Launchcp());
  }

}


appInit() async {
  AppConfigration.initConfig(AppType.DashBord , EnvType.dev, BackendState.remote_dev);
  String lang = "ar";
  
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfigration.FirebaseInit();
  await AppConfigration.backenRoutsdInit();
}
