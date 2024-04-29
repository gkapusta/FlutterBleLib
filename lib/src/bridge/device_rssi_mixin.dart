part of '../_internal.dart';

mixin RssiMixin on FlutterBLE {
  Future<int> rssi(Peripheral peripheral, String transactionId) async {
    return await _methodChannel.invokeMethod(MethodName.rssi, <String, dynamic>{
      ArgumentName.deviceIdentifier: peripheral.identifier,
      ArgumentName.transactionId: transactionId
    }).catchError((errorJson) =>
        Future.error(BleError.fromJson(jsonDecode(errorJson.details))));
  }
}
