import 'package:flutter_ble_lib_example/model/ble_device.dart';
import 'package:rxdart/rxdart.dart';

class MissingPickedDeviceException implements Exception {}

class DeviceRepository {
  static BleDevice? _bleDevice;
  BehaviorSubject<BleDevice?> _deviceController;

  static final DeviceRepository _deviceRepository =
      DeviceRepository._internal();

   factory DeviceRepository() {
    return _deviceRepository;
  }

  DeviceRepository._internal() 
  : _deviceController = BehaviorSubject<BleDevice?>.seeded(_bleDevice);
  

  void pickDevice(BleDevice? bleDevice) {
    _bleDevice = bleDevice;
    _deviceController.add(_bleDevice);
  }

  ValueStream<BleDevice?> get pickedDevice =>
      _deviceController.stream.shareValueSeeded(_bleDevice);

  bool get hasPickedDevice => _bleDevice != null;
}
