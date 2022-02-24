import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';

import '_internal.dart';

abstract class ManagerForPeripheral {
  Future<void> connectToPeripheral(
    String peripheralIdentifier, {
    required bool isAutoConnect,
    required int requestMtu,
    required bool refreshGatt,
    Duration? timeout,
  });

  Future<bool> isPeripheralConnected(String peripheralIdentifier);

  Future<void> disconnectOrCancelPeripheralConnection(
      String peripheralIdentifier);

  Stream<PeripheralConnectionState> observePeripheralConnectionState(
    String peripheralIdentifier,
    bool emitCurrentValue,
    bool completeOnDisconnect,
  );

  Future<void> discoverAllServicesAndCharacteristics(
      Peripheral peripheral, String transactionId);

  Future<List<Service>> services(Peripheral peripheral);

  Future<List<Characteristic>> characteristics(
    Peripheral peripheral,
    String serviceUuid,
  );

  Future<int> rssi(
    Peripheral peripheral,
    String transactionId,
  );

  Future<int> requestMtu(
    Peripheral peripheral,
    int mtu,
    String transactionId,
  );

  Future<CharacteristicWithValue> readCharacteristicForDevice(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String transactionId,
  );

  Future<Characteristic> writeCharacteristicForDevice(
      Peripheral peripheral,
      String serviceUuid,
      String characteristicUuid,
      Uint8List value,
      bool withResponse,
      String transactionId);

  Stream<CharacteristicWithValue> monitorCharacteristicForDevice(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String transactionId,
  );

  Future<List<Descriptor>> descriptorsForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
  );

  Future<DescriptorWithValue> readDescriptorForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    String transactionId,
  );

  Future<Descriptor> writeDescriptorForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  );
}

abstract class ManagerForService {
  Future<List<Characteristic>> characteristicsForService(Service service);

  Future<CharacteristicWithValue> readCharacteristicForService(
    Peripheral peripheral,
    InternalService service,
    String characteristicUuid,
    String transactionId,
  );

  Future<Characteristic> writeCharacteristicForService(
    Peripheral peripheral,
    InternalService service,
    String characteristicUuid,
    Uint8List value,
    bool withResponse,
    String transactionId,
  );

  Stream<CharacteristicWithValue> monitorCharacteristicForService(
    Peripheral peripheral,
    InternalService service,
    String characteristicUuid,
    String transactionId,
  );

  Future<List<Descriptor>> descriptorsForService(
    Service service,
    String characteristicUuid,
  );

  Future<DescriptorWithValue> readDescriptorForService(
    Service service,
    String characteristicUuid,
    String descriptorUuid,
    String transactionId,
  );

  Future<Descriptor> writeDescriptorForService(
    Service service,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  );
}

abstract class ManagerForCharacteristic {
  Future<Uint8List> readCharacteristicForIdentifier(
    Peripheral peripheral,
    InternalCharacteristic characteristic,
    String transactionId,
  );

  Future<void> writeCharacteristicForIdentifier(
    Peripheral peripheral,
    InternalCharacteristic characteristic,
    Uint8List value,
    bool withResponse,
    String transactionId,
  );

  Stream<Uint8List> monitorCharacteristicForIdentifier(
    Peripheral peripheral,
    InternalCharacteristic characteristic,
    String transactionId,
  );

  Future<List<Descriptor>> descriptorsForCharacteristic(
    Characteristic characteristic,
  );

  Future<DescriptorWithValue> readDescriptorForCharacteristic(
    Characteristic characteristic,
    String descriptorUuid,
    String transactionId,
  );

  Future<Descriptor> writeDescriptorForCharacteristic(
    Characteristic characteristic,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  );
}

abstract class ManagerForDescriptor {
  Future<Uint8List> readDescriptorForIdentifier(
    Descriptor descriptor,
    String transactionId,
  );

  Future<void> writeDescriptorForIdentifier(
    Descriptor descriptor,
    Uint8List value,
    String transactionId,
  );
}
