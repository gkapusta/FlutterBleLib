import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib_example/device_details/device_details_bloc.dart';
import 'package:flutter_ble_lib_example/device_details/devices_details_bloc_provider.dart';
import 'package:flutter_ble_lib_example/device_details/view/auto_test_view.dart';
import 'package:flutter_ble_lib_example/device_details/view/manual_test_view.dart';

class DeviceDetailsView extends StatefulWidget {
  @override
  State<DeviceDetailsView> createState() => DeviceDetailsViewState();
}

class DeviceDetailsViewState extends State<DeviceDetailsView> {
  DeviceDetailsBloc? _deviceDetailsBloc;
  StreamSubscription? _appStateSubscription;

  bool _shouldRunOnResume = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Fimber.d("didChangeDependencies");
    if (_deviceDetailsBloc == null) {
      _deviceDetailsBloc = DeviceDetailsBlocProvider.of(context);
      if (_shouldRunOnResume) {
        _shouldRunOnResume = false;
        _onResume();
      }
    }
  }

  void _onResume() {
    Fimber.d("onResume");
    _deviceDetailsBloc?.init();
    _appStateSubscription =
        _deviceDetailsBloc?.disconnectedDevice.listen((bleDevice) async {
      Fimber.d("navigate to details");
      _onPause();
      Navigator.pop(context);
      _shouldRunOnResume = true;
      Fimber.d("back from details");
    });
  }

  void _onPause() {
    Fimber.d("onPause");
    _appStateSubscription?.cancel();
    _deviceDetailsBloc?.dispose();
  }

  @override
  void dispose() {
    Fimber.d("Dispose DeviceListScreenState");
    _onPause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceDetailsBloc = _deviceDetailsBloc;
    return WillPopScope(
      onWillPop: () {
        if (deviceDetailsBloc == null) {
          return Future<bool>.value(true);
        }
        return deviceDetailsBloc.disconnect().then((_) {
          return false;
        });
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              title: Text('Device Details'),
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.autorenew),
                    text: "Automatic",
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    text: "Manual",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                if (deviceDetailsBloc != null)
                  AutoTestView(deviceDetailsBloc),
                if (deviceDetailsBloc != null)
                  ManualTestView(deviceDetailsBloc),
              ],
            )),
      ),
    );
  }
}
