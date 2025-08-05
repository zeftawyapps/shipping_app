import 'package:flutter/material.dart';
import 'package:shipping_app/app-configs.dart';
import 'package:shipping_app/enums.dart';
import 'package:shipping_app/launches.dart';
import 'package:shipping_app/selutions/contral-panal/launch-cp.dart';
import 'package:shipping_app/widgets/map_sample.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  appInit();
  if (AppConfigration.appType == AppType.DashBord  ) {
    setPathUrlStrategy(); // من مكتبة url_strategy
    runApp(const Launchcp());

  } else {

    runApp(const AppLouncher());
  }

}

appInit() async {
  AppConfigration.initConfig(AppType.DashBord, EnvType.dev, BackendState.remote_dev);
  
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfigration.FirebaseInit();
  await AppConfigration.backenRoutsdInit();
}

