part of '../_internal.dart';

mixin DevicesMixin on FlutterBLE {
  Future<List<Peripheral>> knownDevices(
      List<String> peripheralIdentifiers) async {
    return _methodChannel
        .invokeMethod(MethodName.knownDevices, <String, dynamic>{
      ArgumentName.deviceIdentifiers: peripheralIdentifiers,
    }).then((peripheralsJson) {
      debugPrint("known devices json: $peripheralsJson");
      return _parsePeripheralsJson(peripheralsJson);
    });
  }

  Future<List<Peripheral>> connectedDevices(List<String> serviceUuids) async {
    return _methodChannel
        .invokeMethod(MethodName.connectedDevices, <String, dynamic>{
      ArgumentName.uuids: serviceUuids,
    }).then((peripheralsJson) {
      debugPrint("connected devices json: $peripheralsJson");
      return _parsePeripheralsJson(peripheralsJson);
    });
  }

  List<Peripheral> _parsePeripheralsJson(String peripheralsJson) {
    List list = json
        .decode(peripheralsJson)
        .map((peripheral) => Peripheral.fromJson(peripheral, _manager))
        .toList();
    return list.cast<Peripheral>();
  }
}
