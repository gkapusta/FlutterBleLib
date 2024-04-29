part of '../_internal.dart';

mixin DiscoveryMixin on FlutterBLE {
  Future<void> discoverAllServicesAndCharacteristics(
      Peripheral peripheral, String transactionId) async {
    await _methodChannel.invokeMethod(
      MethodName.discoverAllServicesAndCharacteristics,
      <String, dynamic>{
        ArgumentName.deviceIdentifier: peripheral.identifier,
        ArgumentName.transactionId: transactionId,
      },
    ).catchError((errorJson) =>
        Future.error(BleError.fromJson(jsonDecode(errorJson.details))));
  }

  Future<List<Service>> services(Peripheral peripheral) async {
    String jsonString = await _methodChannel.invokeMethod(
      MethodName.services,
      <String, dynamic>{
        ArgumentName.deviceIdentifier: peripheral.identifier,
      },
    ).catchError((errorJson) =>
        Future.error(BleError.fromJson(jsonDecode(errorJson.details))));

    List<Map<String, dynamic>> decodedJson =
        (jsonDecode(jsonString) as List<dynamic>).cast();

    return decodedJson
        .map((serviceJson) =>
            Service.fromJson(serviceJson, peripheral, _manager))
        .toList();
  }

  Future<List<Characteristic>> characteristics(
      Peripheral peripheral, String serviceUuid) async {
    String jsonString = await _methodChannel.invokeMethod(
      MethodName.characteristics,
      <String, dynamic>{
        ArgumentName.deviceIdentifier: peripheral.identifier,
        ArgumentName.serviceUuid: serviceUuid,
      },
    ).catchError((errorJson) =>
        Future.error(BleError.fromJson(jsonDecode(errorJson.details))));

    Map<String, dynamic> jsonObject = jsonDecode(jsonString);
    List<Map<String, dynamic>> jsonCharacteristics =
        (jsonObject["characteristics"] as List<dynamic>).cast();
    Service service = Service.fromJson(jsonObject, peripheral, _manager);

    return jsonCharacteristics.map((characteristicJson) {
      return Characteristic.fromJson(characteristicJson, service, _manager);
    }).toList();
  }

  Future<List<Characteristic>> characteristicsForService(
      Service service) async {
    String jsonString = await _methodChannel.invokeMethod(
      MethodName.characteristicsForService,
      <String, dynamic>{
        ArgumentName.serviceIdentifier: service._id,
      },
    ).catchError((errorJson) =>
        Future.error(BleError.fromJson(jsonDecode(errorJson.details))));

    List<Map<String, dynamic>> jsonList =
        (jsonDecode(jsonString) as List<dynamic>).cast();

    return jsonList.map((characteristicJson) {
      return Characteristic.fromJson(characteristicJson, service, _manager);
    }).toList();
  }

  Future<List<Descriptor>> descriptorsForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
  ) async {
    String jsonString = await _methodChannel
        .invokeMethod(MethodName.descriptorsForDevice, <String, dynamic>{
      ArgumentName.deviceIdentifier: peripheral.identifier,
      ArgumentName.serviceUuid: serviceUuid,
      ArgumentName.characteristicUuid: characteristicUuid,
    }).catchError(
      (errorJson) => Future.error(
        BleError.fromJson(jsonDecode(errorJson.details)),
      ),
    );

    Map<String, dynamic> jsonObject = jsonDecode(jsonString);

    Service service = Service.fromJson(jsonObject, peripheral, _manager);
    Characteristic characteristic =
        Characteristic.fromJson(jsonObject, service, _manager);

    List<Map<String, dynamic>> jsonDescriptors =
        (jsonObject["descriptors"] as List<dynamic>).cast();

    return jsonDescriptors
        .map((jsonDescriptor) =>
            Descriptor.fromJson(jsonDescriptor, characteristic, _manager))
        .toList();
  }

  Future<List<Descriptor>> descriptorsForService(
    Service service,
    String characteristicUuid,
  ) async {
    String jsonString = await _methodChannel
        .invokeMethod(MethodName.descriptorsForService, <String, dynamic>{
      ArgumentName.serviceIdentifier: service._id,
      ArgumentName.characteristicUuid: characteristicUuid,
    }).catchError(
      (errorJson) => Future.error(
        BleError.fromJson(jsonDecode(errorJson.details)),
      ),
    );

    Map<String, dynamic> jsonObject = jsonDecode(jsonString);

    Characteristic characteristic =
        Characteristic.fromJson(jsonObject, service, _manager);

    List<Map<String, dynamic>> jsonDescriptors =
        (jsonObject["descriptors"] as List<dynamic>).cast();

    return jsonDescriptors
        .map((jsonDescriptor) =>
            Descriptor.fromJson(jsonDescriptor, characteristic, _manager))
        .toList();
  }

  Future<List<Descriptor>> descriptorsForCharacteristic(
    Characteristic characteristic,
  ) async {
    String jsonString = await _methodChannel.invokeMethod(
        MethodName.descriptorsForCharacteristic, <String, dynamic>{
      ArgumentName.characteristicIdentifier: characteristic._id,
    }).catchError(
      (errorJson) => Future.error(
        BleError.fromJson(jsonDecode(errorJson.details)),
      ),
    );

    Map<String, dynamic> json = jsonDecode(jsonString);

    List<Map<String, dynamic>> jsonDescriptors =
        (json["descriptors"] as List<dynamic>).cast();
    return jsonDescriptors
        .map((jsonDescriptor) =>
            Descriptor.fromJson(jsonDescriptor, characteristic, _manager))
        .toList();
  }
}
