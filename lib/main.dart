import 'package:flutter/material.dart';
import 'package:shipping_app/selutions/contral-panal/launch-cp.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app-configs.dart';
import 'launches.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  appInit();
  if (AppConfigration.appType == AppType.App) {
    runApp(  AppLouncher());
  } else {
    setPathUrlStrategy(); // من مكتبة url_strategy
    runApp( Launchcp());
  }

}


appInit() async {
  AppConfigration.appType = AppType.DashBord;
  AppConfigration.envType = EnvType.dev;
  String lang = "ar";
  AppConfigration.backendState = BackendState.remote;
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfigration.FirebaseInit();
  await AppConfigration.backenRoutsdInit();
}
