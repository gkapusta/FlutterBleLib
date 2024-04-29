part of '../_internal.dart';

mixin MtuMixin on FlutterBLE {
  Future<int> requestMtu(
      Peripheral peripheral, int mtu, String transactionId) async {
    return await _methodChannel
        .invokeMethod(MethodName.requestMtu, <String, dynamic>{
      ArgumentName.deviceIdentifier: peripheral.identifier,
      ArgumentName.mtu: mtu,
      ArgumentName.transactionId: transactionId
    }).catchError((errorJson) =>
            Future.error(BleError.fromJson(jsonDecode(errorJson.details))));
  }
}
