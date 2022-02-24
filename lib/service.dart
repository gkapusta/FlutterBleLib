part of flutter_ble_lib;

abstract class _ServiceMetadata {
  static const String uuid = "serviceUuid";
  static const String id = "serviceId";
}

/// A collection of [Characteristic]s and associated behaviors.
class Service extends InternalService {
  /// [Peripheral] containing this service.
  Peripheral peripheral;

  final ManagerForService _manager;

  /// The UUID of this service.
  String uuid;

  Service.fromJson(
    Map<String, dynamic> jsonObject,
    Peripheral peripheral,
    this._manager,
  ) : peripheral = peripheral,
      uuid = jsonObject[_ServiceMetadata.uuid],
      super(jsonObject[_ServiceMetadata.id]);

  /// Returns a list of [Characteristic]s of this service.
  Future<List<Characteristic>> characteristics() =>
      _manager.characteristicsForService(this);

  /// Writes the [value] to the [Characteristic] identified by
  /// [characteristicUuid].
  ///
  /// It returns a [Future] that completes with the [Characteristic] for the
  /// convenience of chaining operations.
  ///
  /// Operation will succeed only if [Characteristic] where
  /// [Characteristic.isWritableWithResponse] or
  /// [Characteristic.isWritableWithoutResponse] is `true` and
  /// [withResponse] is specified accordingly can be written to.
  Future<Characteristic> writeCharacteristic(
    String characteristicUuid,
    Uint8List value,
    bool withResponse, {
    String? transactionId,
  }) =>
      _manager.writeCharacteristicForService(
          peripheral,
          this,
          characteristicUuid,
          value,
          withResponse,
          transactionId ?? TransactionIdGenerator.getNextId());

  /// Reads the value of a [Characteristic] identified by [characteristicUuid].
  ///
  /// It returns a [Future] that completes with [CharacteristicWithValue],
  /// which is just a [Characteristic] but with an additonal `value`
  /// property of type [Uint8List]. Only [Characteristic] where
  /// [Characteristic.isReadable] is `true` can be read.
  Future<CharacteristicWithValue> readCharacteristic(
    String characteristicUuid, {
    String? transactionId,
  }) =>
      _manager.readCharacteristicForService(
        peripheral,
        this,
        characteristicUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a [Stream] of values emitted by a [Characteristic] identified by
  /// [characteristicUuid].
  ///
  /// Just like [readCharacteristic()] method, values are emitted as
  /// [CharacteristicWithValue] objects, which are the same as [Characteristic]
  /// but with an additonal `value` property of type [Uint8List]. Only
  /// [Characteristic] where [Characteristic.isNotifiable] is `true` can be
  /// monitored.
  Stream<CharacteristicWithValue> monitorCharacteristic(
    String characteristicUuid, {
    String? transactionId,
  }) =>
      _manager.monitorCharacteristicForService(
        peripheral,
        this,
        characteristicUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a list of [Descriptor]s of a [Characteristic] identified by
  /// [characteristicUuid].
  Future<List<Descriptor>> descriptorsForCharacteristic(
    String characteristicUuid,
  ) =>
      _manager.descriptorsForService(
        this,
        characteristicUuid,
      );

  /// Reads the value of a [Descriptor] identified by [descriptorUuid] of
  /// a [Characteristic] identified by [characteristicUuid].
  ///
  /// It returns a [Future] that completes with [DescriptorWithValue],
  /// which is just a [Descriptor] but with an additonal `value` property
  /// of type [Uint8List].
  Future<DescriptorWithValue> readDescriptor(
    String characteristicUuid,
    String descriptorUuid, {
    String? transactionId,
  }) =>
      _manager.readDescriptorForService(
        this,
        characteristicUuid,
        descriptorUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes the [value] of a [Descriptor] identified by [descriptorUuid]
  /// of a [Characteristic] identified by [characteristicUuid].
  ///
  /// It returns a [Future] that completes with the [Descriptor].
  Future<Descriptor> writeDescriptor(
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value, {
    String? transactionId,
  }) =>
      _manager.writeDescriptorForService(
        this,
        characteristicUuid,
        descriptorUuid,
        value,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service &&
          runtimeType == other.runtimeType &&
          peripheral.identifier == other.peripheral.identifier &&
          uuid == other.uuid;

  @override
  int get hashCode => peripheral.hashCode ^ _manager.hashCode ^ uuid.hashCode;

  /// Returns a string representation of this service in a format that exposes
  /// [Peripheral.identifier] and [uuid].
  @override
  String toString() {
    return 'Service{peripheralId: ${peripheral.identifier}, uuid: $uuid}';
  }
}
