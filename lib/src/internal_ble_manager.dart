part of _internal;

class InternalBleManager
    implements
        BleManager,
        ManagerForPeripheral,
        ManagerForService,
        ManagerForCharacteristic,
        ManagerForDescriptor {
  late FlutterBleLib _bleLib;
  
  InternalBleManager() {
    _bleLib = FlutterBleLib(this);
  }

  @override
  Future<bool> isClientCreated() => _bleLib.isClientCreated();

  @override
  Future<void> createClient({
    String? restoreStateIdentifier,
    RestoreStateAction? restoreStateAction,
  }) {
    if (restoreStateAction != null) {
      _bleLib.restoredState().then((devices) {
        restoreStateAction(devices);
      });
    }
    return _bleLib.createClient(restoreStateIdentifier);
  }

  @override
  Future<void> destroyClient() => _bleLib.destroyClient();

  @override
  Future<void> cancelTransaction(String transactionId) =>
      _bleLib.cancelTransaction(transactionId);

  @override
  Future<void> enableRadio({String? transactionId}) =>
      _bleLib.enableRadio(transactionId ?? TransactionIdGenerator.getNextId());

  @override
  Future<void> disableRadio({String? transactionId}) =>
      _bleLib.disableRadio(transactionId ?? TransactionIdGenerator.getNextId());

  @override
  Future<BluetoothState> bluetoothState() => _bleLib.state();

  @override
  Stream<BluetoothState> observeBluetoothState(
          {bool emitCurrentValue = true}) =>
      _bleLib.observeBluetoothState(emitCurrentValue);

  @override
  Stream<ScanResult> startPeripheralScan({
    int scanMode = ScanMode.lowPower,
    int callbackType = CallbackType.allMatches,
    List<String> uuids = const [],
    bool allowDuplicates = false,
  }) =>
      _bleLib.startDeviceScan(scanMode, callbackType, uuids, allowDuplicates);

  @override
  Future<void> stopPeripheralScan() => _bleLib.stopDeviceScan();

  @override
  Peripheral createUnsafePeripheral(String peripheralId, {String? name}) {
    const nameField = 'name';
    const identifierField = 'id';
    return Peripheral.fromJson({
      nameField: name,
      identifierField: peripheralId,
    }, this);
  }

  @override
  Future<void> connectToPeripheral(
    String identifier, {
    required bool isAutoConnect,
    required int requestMtu,
    required bool refreshGatt,
    Duration? timeout,
  }) async =>
      _bleLib.connectToPeripheral(
          identifier, isAutoConnect, requestMtu, refreshGatt, timeout);

  @override
  Stream<PeripheralConnectionState> observePeripheralConnectionState(
      String peripheralIdentifier,
      bool emitCurrentValue,
      bool completeOnDisconnect) {
    var streamTransformer = StreamTransformer<PeripheralConnectionState,
            PeripheralConnectionState>.fromHandlers(
        handleData: (PeripheralConnectionState data, EventSink sink) {
          sink.add(data);
          if (data == PeripheralConnectionState.disconnected) {
            sink.close();
          }
        },
        handleError: (Object error, StackTrace stacktrace, EventSink sink) {
          sink.addError(error);
        },
        handleDone: (EventSink sink) => sink.close());

    var stream = _bleLib.observePeripheralConnectionState(
        peripheralIdentifier, emitCurrentValue);
    if (completeOnDisconnect) {
      return stream.transform(streamTransformer);
    } else {
      return stream;
    }
  }

  @override
  Future<void> disconnectOrCancelPeripheralConnection(
          String peripheralIdentifier) =>
      _bleLib.disconnectOrCancelPeripheralConnection(peripheralIdentifier);

  @override
  Future<bool> isPeripheralConnected(String peripheralIdentifier) =>
      _bleLib.isPeripheralConnected(peripheralIdentifier);

  @override
  Future<LogLevel> logLevel() {
    return _bleLib.logLevel();
  }

  @override
  Future<void> setLogLevel(LogLevel logLevel) {
    return _bleLib.setLogLevel(logLevel);
  }

  @override
  Future<List<Characteristic>> characteristics(
    Peripheral peripheral,
    String serviceUuid,
  ) =>
      _bleLib.characteristics(peripheral, serviceUuid);

  @override
  Future<List<Service>> services(Peripheral peripheral) =>
      _bleLib.services(peripheral);

  @override
  Future<List<Descriptor>> descriptorsForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
  ) =>
      _bleLib.descriptorsForPeripheral(
          peripheral, serviceUuid, characteristicUuid);

  @override
  Future<List<Descriptor>> descriptorsForService(
    Service service,
    String characteristicUuid,
  ) =>
      _bleLib.descriptorsForService(service, characteristicUuid);

  @override
  Future<List<Descriptor>> descriptorsForCharacteristic(
          Characteristic characteristic) =>
      _bleLib.descriptorsForCharacteristic(characteristic);

  @override
  Future<void> discoverAllServicesAndCharacteristics(
    Peripheral peripheral,
    String transactionId,
  ) =>
      _bleLib.discoverAllServicesAndCharacteristics(peripheral, transactionId);

  @override
  Future<List<Characteristic>> characteristicsForService(Service service) =>
      _bleLib.characteristicsForService(service);

  @override
  Future<int> rssi(
    Peripheral peripheral,
    String transactionId,
  ) {
    print("call channel read RSSI");
    return _bleLib.rssi(peripheral, transactionId);
  }

  @override
  Future<int> requestMtu(
      Peripheral peripheral, int mtu, String transactionId) {
    return _bleLib.requestMtu(peripheral, mtu, transactionId);
  }

  @override
  Future<List<Peripheral>> knownPeripherals(
      List<String> peripheralIdentifiers) {
    return _bleLib.knownDevices(peripheralIdentifiers);
  }

  @override
  Future<List<Peripheral>> connectedPeripherals(List<String> serviceUuids) {
    return _bleLib.connectedDevices(serviceUuids);
  }

  @override
  Future<Uint8List> readCharacteristicForIdentifier(
    Peripheral peripheral,
    InternalCharacteristic characteristic,
    String transactionId,
  ) =>
      _bleLib.readCharacteristicForIdentifier(
          peripheral, characteristic._id, transactionId);

  @override
  Future<CharacteristicWithValue> readCharacteristicForDevice(
          Peripheral peripheral,
          String serviceUuid,
          String characteristicUuid,
          String transactionId) =>
      _bleLib.readCharacteristicForDevice(
        peripheral,
        serviceUuid,
        characteristicUuid,
        transactionId,
      );

  @override
  Future<CharacteristicWithValue> readCharacteristicForService(
          Peripheral peripheral,
          InternalService service,
          String characteristicUuid,
          String transactionId) =>
      _bleLib.readCharacteristicForService(
        peripheral,
        service._id,
        characteristicUuid,
        transactionId,
      );

  @override
  Future<void> writeCharacteristicForIdentifier(
          Peripheral peripheral,
          InternalCharacteristic characteristic,
          Uint8List value,
          bool withResponse,
          String transactionId) =>
      _bleLib.writeCharacteristicForIdentifier(
        peripheral,
        characteristic._id,
        value,
        withResponse,
        transactionId,
      );

  @override
  Future<Characteristic> writeCharacteristicForDevice(
          Peripheral peripheral,
          String serviceUuid,
          String characteristicUuid,
          Uint8List value,
          bool withResponse,
          String transactionId) =>
      _bleLib.writeCharacteristicForDevice(
        peripheral,
        serviceUuid,
        characteristicUuid,
        value,
        withResponse,
        transactionId,
      );

  @override
  Future<Characteristic> writeCharacteristicForService(
          Peripheral peripheral,
          InternalService service,
          String characteristicUuid,
          Uint8List value,
          bool withResponse,
          String transactionId) =>
      _bleLib.writeCharacteristicForService(
        peripheral,
        service._id,
        characteristicUuid,
        value,
        withResponse,
        transactionId,
      );

  @override
  Stream<CharacteristicWithValue> monitorCharacteristicForDevice(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String transactionId,
  ) =>
      _bleLib.monitorCharacteristicForDevice(
        peripheral,
        serviceUuid,
        characteristicUuid,
        transactionId,
      );

  @override
  Stream<CharacteristicWithValue> monitorCharacteristicForService(
    Peripheral peripheral,
    InternalService service,
    String characteristicUuid,
    String transactionId,
  ) =>
      _bleLib.monitorCharacteristicForService(
        peripheral,
        service._id,
        characteristicUuid,
        transactionId,
      );

  @override
  Stream<Uint8List> monitorCharacteristicForIdentifier(
    Peripheral peripheral,
    InternalCharacteristic characteristic,
    String transactionId,
  ) =>
      _bleLib.monitorCharacteristicForIdentifier(
        peripheral,
        characteristic._id,
        transactionId,
      );

  @override
  Future<void> writeDescriptorForIdentifier(
    Descriptor descriptor,
    Uint8List value,
    String transactionId,
  ) =>
      _bleLib.writeDescriptorForIdentifier(
        descriptor,
        value,
        transactionId,
      );

  @override
  Future<Descriptor> writeDescriptorForCharacteristic(
    Characteristic characteristic,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  ) =>
      _bleLib.writeDescriptorForCharacteristic(
        characteristic,
        descriptorUuid,
        value,
        transactionId,
      );

  @override
  Future<Descriptor> writeDescriptorForService(
    Service service,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  ) =>
      _bleLib.writeDescriptorForService(
        service,
        characteristicUuid,
        descriptorUuid,
        value,
        transactionId,
      );

  @override
  Future<Descriptor> writeDescriptorForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value,
    String transactionId,
  ) =>
      _bleLib.writeDescriptorForPeripheral(
        peripheral,
        serviceUuid,
        characteristicUuid,
        descriptorUuid,
        value,
        transactionId,
      );

  @override
  Future<Uint8List> readDescriptorForIdentifier(
    Descriptor descriptor,
    String transactionId,
  ) =>
      _bleLib.readDescriptorForIdentifier(
        descriptor,
        transactionId,
      );

  @override
  Future<DescriptorWithValue> readDescriptorForCharacteristic(
    Characteristic characteristic,
    String descriptorUuid,
    String transactionId,
  ) =>
      _bleLib.readDescriptorForCharacteristic(
        characteristic,
        descriptorUuid,
        transactionId,
      );

  @override
  Future<DescriptorWithValue> readDescriptorForService(
    Service service,
    String characteristicUuid,
    String descriptorUuid,
    String transactionId,
  ) =>
      _bleLib.readDescriptorForService(
        service,
        characteristicUuid,
        descriptorUuid,
        transactionId,
      );

  @override
  Future<DescriptorWithValue> readDescriptorForPeripheral(
    Peripheral peripheral,
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    String transactionId,
  ) =>
      _bleLib.readDescriptorForPeripheral(
        peripheral,
        serviceUuid,
        characteristicUuid,
        descriptorUuid,
        transactionId,
      );
}
