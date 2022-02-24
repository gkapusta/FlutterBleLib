import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib_example/devices_list/devices_bloc_provider.dart';
import 'package:flutter_ble_lib_example/devices_list/devices_list_view.dart';

import 'device_details/device_detail_view.dart';
import 'device_details/devices_details_bloc_provider.dart';

void main() {
  Fimber.plantTree(DebugTree());
  runApp(MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBleLib example',
      theme: new ThemeData(
        primaryColor: new Color(0xFF0A3D91),
        accentColor: new Color(0xFFCC0000),
      ),
      initialRoute: "/",
      routes: <String, WidgetBuilder>{
        "/": (context) => DevicesBlocProvider(child: DevicesListScreen()),
        "/details": (context) =>
            DeviceDetailsBlocProvider(child: DeviceDetailsView()),
      },
      navigatorObservers: [routeObserver],
    );
  }
}
