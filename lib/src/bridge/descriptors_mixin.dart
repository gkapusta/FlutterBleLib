part of '../_internal.dart';

mixin DescriptorsMixin on FlutterBLE {
  Future<DescriptorWithValue> readDescriptorForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.readDescriptorForDevice,
            <String, dynamic>{
              ArgumentName.deviceIdentifier: peripheral.identifier,
              ArgumentName.serviceUuid: serviceUuid,
              ArgumentName.characteristicUuid: characteristicUuid,
              ArgumentName.descriptorUuid: descriptorUuid,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);
            Service service =
                Service.fromJson(jsonObject, peripheral, _manager);
            Characteristic characteristic =
                Characteristic.fromJson(jsonObject, service, _manager);
            return DescriptorWithValue.fromJson(
                jsonObject, characteristic, _manager);
          });

  Future<DescriptorWithValue> readDescriptorForService(
    Service service,
    String characteristicUuid,
    String descriptorUuid,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.readDescriptorForService,
            <String, dynamic>{
              ArgumentName.serviceIdentifier: service._id,
              ArgumentName.characteristicUuid: characteristicUuid,
              ArgumentName.descriptorUuid: descriptorUuid,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);
            Characteristic characteristic =
                Characteristic.fromJson(jsonObject, service, _manager);
            return DescriptorWithValue.fromJson(
                jsonObject, characteristic, _manager);
          });

  Future<DescriptorWithValue> readDescriptorForCharacteristic(
    Characteristic characteristic,
    String descriptorUuid,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.readDescriptorForCharacteristic,
            <String, dynamic>{
              ArgumentName.characteristicIdentifier: characteristic._id,
              ArgumentName.descriptorUuid: descriptorUuid,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);

            return DescriptorWithValue.fromJson(
                jsonObject, characteristic, _manager);
          });

  Future<Uint8List> readDescriptorForIdentifier(
    Descriptor descriptor,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.readDescriptorForIdentifier,
            <String, dynamic>{
              ArgumentName.descriptorIdentifier: descriptor._id,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);
            return DescriptorWithValue.fromJson(
                    jsonObject, descriptor.characteristic, _manager)
                .value;
          });

  Future<Descriptor> writeDescriptorForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.writeDescriptorForDevice,
            <String, dynamic>{
              ArgumentName.deviceIdentifier: peripheral.identifier,
              ArgumentName.serviceUuid: serviceUuid,
              ArgumentName.characteristicUuid: characteristicUuid,
              ArgumentName.descriptorUuid: descriptorUuid,
              ArgumentName.value: value,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);
            Service service =
                Service.fromJson(jsonObject, peripheral, _manager);
            Characteristic characteristic =
                Characteristic.fromJson(jsonObject, service, _manager);
            return Descriptor.fromJson(jsonObject, characteristic, _manager);
          });

  Future<Descriptor> writeDescriptorForService(
    Service service,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.writeDescriptorForService,
            <String, dynamic>{
              ArgumentName.serviceIdentifier: service._id,
              ArgumentName.characteristicUuid: characteristicUuid,
              ArgumentName.descriptorUuid: descriptorUuid,
              ArgumentName.value: value,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);
            Characteristic characteristic =
                Characteristic.fromJson(jsonObject, service, _manager);
            return Descriptor.fromJson(jsonObject, characteristic, _manager);
          });

  Future<Descriptor> writeDescriptorForCharacteristic(
    Characteristic characteristic,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  ) =>
      _methodChannel
          .invokeMethod(
            MethodName.writeDescriptorForCharacteristic,
            <String, dynamic>{
              ArgumentName.characteristicIdentifier: characteristic._id,
              ArgumentName.descriptorUuid: descriptorUuid,
              ArgumentName.value: value,
              ArgumentName.transactionId: transactionId,
            },
          )
          .catchError(_handleError)
          .then((jsonResponse) {
            Map<String, dynamic> jsonObject = jsonDecode(jsonResponse);
            return Descriptor.fromJson(jsonObject, characteristic, _manager);
          });

  Future<void> writeDescriptorForIdentifier(
    Descriptor descriptor,
    Uint8List value,
    String transactionId,
  ) =>
      _methodChannel.invokeMethod(
        MethodName.writeDescriptorForIdentifier,
        <String, dynamic>{
          ArgumentName.descriptorIdentifier: descriptor._id,
          ArgumentName.value: value,
          ArgumentName.transactionId: transactionId,
        },
      ).catchError(_handleError);

  Future<void> _handleError(
    Object error, [
    dynamic stacktrace,
  ]) =>
      Future.error(
        BleError.fromJson(
          jsonDecode(
            (error as PlatformException).details,
          ),
        ),
      );
}
