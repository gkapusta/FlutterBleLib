part of flutter_ble_lib;

abstract class _CharacteristicMetadata {
  static const String uuid = "characteristicUuid";
  static const String id = "id";
  static const String isReadable = "isReadable";
  static const String isWritableWithResponse = "isWritableWithResponse";
  static const String isWritableWithoutResponse = "isWritableWithoutResponse";
  static const String isNotifiable = "isNotifiable";
  static const String isIndicatable = "isIndicatable";
  static const String value = "value";
}

/// Representation of a single GATT Characteristic nested inside a [Service].
///
/// It contains a single value and any number of [Descriptor]s describing that
/// value. The properties of a characteristic determine how you can use
/// a characteristic’s value, and how you access the descriptors.
class Characteristic extends InternalCharacteristic {
  /// The [Service] containing this characteristic.
  final Service service;

  final ManagerForCharacteristic _manager;

  /// The UUID of this characteristic.
  String uuid;

  /// True if this characteristic can be read.
  bool isReadable;

  /// True if this characteristic can be written with resposne.
  bool isWritableWithResponse;

  /// True if this characteristic can be written without resposne.
  bool isWritableWithoutResponse;

  /// True if this characteristic can be monitored via notifications.
  bool isNotifiable;

  /// True if this characteristic can be monitored via indications.
  bool isIndicatable;

  Characteristic.fromJson(Map<String, dynamic> jsonObject, Service service,
      ManagerForCharacteristic manager)
      : _manager = manager,
        service = service,
        uuid = jsonObject[_CharacteristicMetadata.uuid],
        isReadable = jsonObject[_CharacteristicMetadata.isReadable],
        isWritableWithResponse =
            jsonObject[_CharacteristicMetadata.isWritableWithResponse],
        isWritableWithoutResponse =
            jsonObject[_CharacteristicMetadata.isWritableWithoutResponse],
        isNotifiable = jsonObject[_CharacteristicMetadata.isNotifiable],
        isIndicatable = jsonObject[_CharacteristicMetadata.isIndicatable],
        super(jsonObject[_CharacteristicMetadata.id]);

  /// Reads the value of this characteristic.
  ///
  /// The value can be read only if [isReadable] is `true`.
  Future<Uint8List> read({String? transactionId}) =>
      _manager.readCharacteristicForIdentifier(
        service.peripheral,
        this,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes to the value of this characteristic.
  ///
  /// The value can be written only if [isWritableWithResponse] or
  /// [isWritableWithoutResponse] is `true` and argument [withResponse] is
  /// set accordingly.
  Future<void> write(
    Uint8List value,
    bool withResponse, {
    String? transactionId,
  }) =>
      _manager.writeCharacteristicForIdentifier(
        service.peripheral,
        this,
        value,
        withResponse,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a [Stream] of notifications/indications emitted by this
  /// characteristic.
  ///
  /// Library chooses notifications over indications, if both are supported.
  ///
  /// Subscribing to the returned object enables the notifications/indications
  /// on the peripheral. Cancelling the last subscription disables the
  /// notifications/indications on this characteristic.
  Stream<Uint8List> monitor({String? transactionId}) =>
      _manager.monitorCharacteristicForIdentifier(
        service.peripheral,
        this,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a list of [Descriptor]s of this characteristic.
  Future<List<Descriptor>> descriptors() =>
      _manager.descriptorsForCharacteristic(this);

  /// Reads the value of a [Descriptor] identified by [descriptorUuid].
  Future<DescriptorWithValue> readDescriptor(
    String descriptorUuid, {
    String? transactionId,
  }) =>
      _manager.readDescriptorForCharacteristic(
        this,
        descriptorUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes the [value] of a [Descriptor] identified by [descriptorUuid].
  Future<Descriptor> writeDescriptor(
    String descriptorUuid,
    Uint8List value, {
    String? transactionId,
  }) =>
      _manager.writeDescriptorForCharacteristic(
        this,
        descriptorUuid,
        value,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Characteristic &&
          runtimeType == other.runtimeType &&
          service == other.service &&
          uuid == other.uuid &&
          isReadable == other.isReadable &&
          isWritableWithResponse == other.isWritableWithResponse &&
          isWritableWithoutResponse == other.isWritableWithoutResponse &&
          isNotifiable == other.isNotifiable &&
          isIndicatable == other.isIndicatable;

  @override
  int get hashCode =>
      service.hashCode ^
      _manager.hashCode ^
      uuid.hashCode ^
      isReadable.hashCode ^
      isWritableWithResponse.hashCode ^
      isWritableWithoutResponse.hashCode ^
      isNotifiable.hashCode ^
      isIndicatable.hashCode;

  /// Returns a string representation of this characteristic in a format that
  /// contains all its properties and [Service].
  @override
  String toString() {
    return 'Characteristic{service: $service,'
        ' _manager: $_manager,'
        ' uuid: $uuid,'
        ' isReadable: $isReadable,'
        ' isWritableWithResponse: $isWritableWithResponse,'
        ' isWritableWithoutResponse: $isWritableWithoutResponse,'
        ' isNotifiable: $isNotifiable,'
        ' isIndicatable: $isIndicatable}';
  }
}

/// [Characteristic] extended with [value] property.
///
/// This type is created to support chaining of operations on the characteristic
/// when it was first read from [Peripheral] or [Service].
class CharacteristicWithValue extends Characteristic {
  Uint8List value;

  CharacteristicWithValue.fromJson(
    Map<String, dynamic> jsonObject,
    Service service,
    ManagerForCharacteristic manager,
  ) : value = base64Decode(jsonObject[_CharacteristicMetadata.value]),
      super.fromJson(jsonObject, service, manager);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        super == other &&
            other is CharacteristicWithValue &&
            value.toString() == other.value.toString() &&
            runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => super.hashCode;

  @override
  String toString() {
    return super.toString() +
        ' CharacteristicWithValue{value = ${value.toString()}';
  }
}
