part of flutter_ble_lib;

abstract class _DescriptorMetadata {
  static const String uuid = 'descriptorUuid';
  static const String id = 'descriptorId';
  static const String value = 'value';
}

class Descriptor extends InternalDescriptor {
  final ManagerForDescriptor _manager;
  final Characteristic characteristic;
  final String uuid;

  Descriptor.fromJson(
    Map<String, dynamic> jsonObject,
    Characteristic characteristic,
    ManagerForDescriptor manager,
  ) : _manager = manager,
      characteristic = characteristic,
      uuid = jsonObject[_DescriptorMetadata.uuid],
      super(jsonObject[_DescriptorMetadata.id]);

  Future<Uint8List> read({String? transactionId}) =>
      _manager.readDescriptorForIdentifier(
        this,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  Future<void> write(Uint8List value, {String? transactionId}) =>
      _manager.writeDescriptorForIdentifier(
        this,
        value,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Descriptor &&
          runtimeType == other.runtimeType &&
          _manager == other._manager &&
          characteristic == other.characteristic &&
          uuid == other.uuid;

  @override
  int get hashCode =>
      _manager.hashCode ^ characteristic.hashCode ^ uuid.hashCode;
}

class DescriptorWithValue extends Descriptor {
  Uint8List value;

  DescriptorWithValue.fromJson(
    Map<String, dynamic> jsonObject,
    Characteristic characteristic,
    ManagerForDescriptor manager,
  ) : value = base64Decode(jsonObject[_DescriptorMetadata.value]),
      super.fromJson(jsonObject, characteristic, manager);
}
