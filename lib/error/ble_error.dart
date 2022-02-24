part of flutter_ble_lib;

abstract class _BleErrorMetadata {
  static const String errorCode = "errorCode";
  static const String attErrorCode = "attErrorCode";
  static const String iosErrorCode = "iosErrorCode";
  static const String androidErrorCode = "androidErrorCode";
  static const String reason = "reason";
  static const String deviceId = "deviceID";
  static const String serviceUuid = "serviceUUID";
  static const String characteristicUuid = "characteristicUUID";
  static const String descriptorUuid = "descriptorUUID";
  static const String internalMessage = "internalMessage";
}

class BleError {
  final BleErrorCode errorCode;
  final int? attErrorCode;
  final int? iosErrorCode;
  final int? androidErrorCode;
  final String reason;

  final String? deviceID;
  final String? serviceUuid;
  final String? characteristicUuid;
  final String? descriptorUuid;
  final String? internalMessage;

  BleError.fromJson(Map<String, dynamic> json)
      : errorCode = BleErrorCode(json[_BleErrorMetadata.errorCode] ?? 0),
        attErrorCode = json[_BleErrorMetadata.attErrorCode],
        iosErrorCode = json[_BleErrorMetadata.iosErrorCode],
        androidErrorCode = json[_BleErrorMetadata.androidErrorCode],
        reason = json[_BleErrorMetadata.reason] ?? "Reason not provided",
        deviceID = json[_BleErrorMetadata.deviceId],
        serviceUuid = json[_BleErrorMetadata.serviceUuid],
        characteristicUuid = json[_BleErrorMetadata.characteristicUuid],
        descriptorUuid = json[_BleErrorMetadata.descriptorUuid],
        internalMessage = json[_BleErrorMetadata.internalMessage];

  @override
  String toString() => "BleError ("
      "Error code: ${errorCode.value}, "
      "ATT error code: $attErrorCode, "
      "iOS error code: $iosErrorCode, "
      "Android error code: $androidErrorCode, "
      "reason: $reason, "
      "internal message: $internalMessage, "
      "device ID: $deviceID, "
      "service UUID: $serviceUuid, "
      "characteristic UUID: $characteristicUuid, "
      "descriptor UUID: $descriptorUuid)";
}

class BleErrorCode {
  static const int unknownError = 0;
  static const int bluetoothManagerDestroyed = 1;
  static const int operationCancelled = 2;
  static const int operationTimedOut = 3;
  static const int operationStartFailed = 4;
  static const int invalidIdentifiers = 5;

  static const int bluetoothUnsupported = 100;
  static const int bluetoothUnauthorized = 101;
  static const int bluetoothPoweredOff = 102;
  static const int bluetoothInUnknownState = 103;
  static const int bluetoothResetting = 104;
  static const int bluetoothStateChangeFailed = 105;

  static const int deviceConnectionFailed = 200;
  static const int deviceDisconnected = 201;
  static const int deviceRSSIReadFailed = 202;
  static const int deviceAlreadyConnected = 203;
  static const int deviceNotFound = 204;
  static const int deviceNotConnected = 205;
  static const int deviceMTUChangeFailed = 206;

  static const int servicesDiscoveryFailed = 300;
  static const int includedServicesDiscoveryFailed = 301;
  static const int serviceNotFound = 302;
  static const int servicesNotDiscovered = 303;

  static const int characteristicsDiscoveryFailed = 400;
  static const int characteristicWriteFailed = 401;
  static const int characteristicReadFailed = 402;
  static const int characteristicNotifyChangeFailed = 403;
  static const int characteristicNotFound = 404;
  static const int characteristicsNotDiscovered = 405;
  static const int characteristicInvalidDataFormat = 406;

  static const int descriptorsDiscoveryFailed = 500;
  static const int descriptorWriteFailed = 501;
  static const int descriptorReadFailed = 502;
  static const int descriptorNotFound = 503;
  static const int descriptorsNotDiscovered = 504;
  static const int descriptorInvalidDataFormat = 505;
  static const int descriptorWriteNotAllowed = 506;

  static const int scanStartFailed = 600;
  static const int locationServicesDisabled = 601;

  int value;

  BleErrorCode(this.value);
}
