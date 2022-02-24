import 'package:flutter/widgets.dart';

import 'device_details_bloc.dart';

class DeviceDetailsBlocProvider extends InheritedWidget {
  final DeviceDetailsBloc _deviceDetailsBloc;

  DeviceDetailsBlocProvider({
    Key? key,
    DeviceDetailsBloc? deviceDetailsBloc,
    required Widget child,
  }) 
  : _deviceDetailsBloc = deviceDetailsBloc ?? DeviceDetailsBloc(),
    super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static DeviceDetailsBloc of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<DeviceDetailsBlocProvider>()
      !._deviceDetailsBloc;
}
