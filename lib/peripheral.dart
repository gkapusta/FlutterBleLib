part of flutter_ble_lib;

abstract class _PeripheralMetadata {
  static const name = "name";
  static const identifier = "id";
}

/// Representation of a unique peripheral
///
/// This class allows for managing the connection, discovery,
/// retrieving [Service]s, [Characteristic]s and [Descriptor]s and has
/// convenience methods for manipulation of the latter two.
///
/// Only [connect()], [observeConnectionState()], [isConnected()] and
/// [disconnectOrCancelConnection()] can be used if peripheral is not connected.
class Peripheral {
  static const int NO_MTU_NEGOTIATION = 0;
  final ManagerForPeripheral _manager;

  String? name;
  String identifier;

  Peripheral.fromJson(Map<String, dynamic> json, ManagerForPeripheral manager)
      : _manager = manager,
        name = json[_PeripheralMetadata.name],
        identifier = json[_PeripheralMetadata.identifier];

  /// Connects to the peripheral.
  ///
  /// Optional [isAutoConnect] controls whether to directly connect to the
  /// remote peripheral (`false`) or to automatically connect as soon as the
  /// remote peripheral becomes available (true). (Android only)
  ///
  /// Optional [requestMtu] size will be negotiated to this value. It is not
  /// guaranteed to get it after connection is successful. (Android only)
  /// iOS by default requests about 186 MTU size and there's nothing anyone can
  /// do about it.
  /// **NOTE**: if MTU has been requested on this step, then there's no way
  /// to retrieve its value later on.
  ///
  /// Passing `true` as [refreshGatt] will reset services cache. This option may
  /// be useful when a peripheral's firmware was updated and it's
  /// services/characteristics were added/removed/altered. (Android only)
  ///
  /// Optional [timeout] is used to define delay after which the connection is
  /// automatically cancelled. In case of race condition were connection
  /// is established right after timeout event, peripheral will be disconnected
  /// immediately. Timeout may happen earlier than specified due to OS
  /// specific behavior.
  Future<void> connect(
          {bool isAutoConnect = false,
          int requestMtu = NO_MTU_NEGOTIATION,
          bool refreshGatt = false,
          Duration? timeout}) =>
      _manager.connectToPeripheral(identifier,
          isAutoConnect: isAutoConnect,
          requestMtu: requestMtu,
          refreshGatt: refreshGatt,
          timeout: timeout);

  /// Returns a stream of [PeripheralConnectionState].
  ///
  /// By default this stream will never end, but this behaviour can be changed
  /// by setting [completeOnDisconnect] to `true`.
  Stream<PeripheralConnectionState> observeConnectionState(
          {bool emitCurrentValue = false, bool completeOnDisconnect = false}) =>
      _manager.observePeripheralConnectionState(
          identifier, emitCurrentValue, completeOnDisconnect);

  /// Returns whether this peripheral is connected.
  Future<bool> isConnected() => _manager.isPeripheralConnected(identifier);

  /// Disconnects from this peripheral if it's connected or cancels pending
  /// connection.
  Future<void> disconnectOrCancelConnection() =>
      _manager.disconnectOrCancelPeripheralConnection(identifier);

  /// Discovers all [Service]s, [Characteristic]s and [Descriptor]s of this peripheral.
  /// Must be done prior to any other operation concerning those.
  ///
  /// Optional [transactionId] could be used to cancel operation.
  Future<void> discoverAllServicesAndCharacteristics({String? transactionId}) =>
      _manager.discoverAllServicesAndCharacteristics(
          this, transactionId ?? TransactionIdGenerator.getNextId());

  /// Returns a list of [Service]s of this peripheral.
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<List<Service>> services() => _manager.services(this);

  /// Returns a list of discovered [Characteristic]s of a [Service] identified
  /// by [servicedUuid].
  ///
  /// [servicedUuid] must be specified as characteristics only for that
  /// service are returned.
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<List<Characteristic>> characteristics(String servicedUuid) =>
      _manager.characteristics(this, servicedUuid);

  /// Reads RSSI for the peripheral.
  ///
  /// Optional [transactionId] could be used to cancel operation.
  Future<int> rssi({String? transactionId}) =>
      _manager.rssi(this, transactionId ?? TransactionIdGenerator.getNextId());

  /// Requests new MTU value for current connection and return the negotiation
  /// result on Android, reads MTU on iOS.
  ///
  /// This function currently is not doing anything on iOS platform as
  /// MTU is requested automatically around 186.
  ///
  /// Peripheral will negotiate requested [mtu], meaning it might be actually
  /// lower than the requested size.
  /// Optional [transactionId] could be used to cancel operation.
  ///
  /// If MTU has been requested in [connect()] this method will end with [BleError].
  Future<int> requestMtu(int mtu, {String? transactionId}) =>
      _manager.requestMtu(
          this, mtu, transactionId ?? TransactionIdGenerator.getNextId());

  /// Reads value of [Characteristic] matching specified UUIDs.
  ///
  /// Returns value of characteristic with [characteristicUuid] for service with
  /// [serviceUuid]. Optional [transactionId] could be used to cancel operation.
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<CharacteristicWithValue> readCharacteristic(
    String serviceUuid,
    String characteristicUuid, {
    String? transactionId,
  }) =>
      _manager.readCharacteristicForDevice(
        this,
        serviceUuid,
        characteristicUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes value of [Characteristic] matching specified UUIDs.
  ///
  /// Writes [value] to characteristic with [characteristicUuid] for service with
  /// [serviceUuid]. Optional [transactionId] could be used to cancel operation.
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<Characteristic> writeCharacteristic(
    String serviceUuid,
    String characteristicUuid,
    Uint8List value,
    bool withResponse, {
    String? transactionId,
  }) =>
      _manager.writeCharacteristicForDevice(
        this,
        serviceUuid,
        characteristicUuid,
        value,
        withResponse,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a list of [Descriptor]s for [Characteristic] matching specified UUIDs.
  ///
  /// Returns list of discovered Descriptors for given [serviceUuid] in specified
  /// characteristic with [characteristicUuid]
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<List<Descriptor>> descriptorsForCharacteristic(
    String serviceUuid,
    String characteristicUuid,
  ) =>
      _manager.descriptorsForPeripheral(this, serviceUuid, characteristicUuid);

  /// Reads value of [Descriptor] matching specified UUIDs.
  ///
  /// Returns Descriptor object matching specified [serviceUuid],
  /// [characteristicUuid] and [descriptorUuid]. Latest value of the descriptor will
  /// be stored inside returned object. Optional [transactionId] could be used
  /// to cancel operation.
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<DescriptorWithValue> readDescriptor(
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid, {
    String? transactionId,
  }) =>
      _manager.readDescriptorForPeripheral(
        this,
        serviceUuid,
        characteristicUuid,
        descriptorUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Writes value of [Descriptor] matching specified UUIDs.
  ///
  /// Write [value] to Descriptor specified by [serviceUuid],
  /// [characteristicUuid] and [descriptorUuid]. Returns Descriptor which saved
  /// passed value. Optional [transactionId] could be used to cancel operation.
  ///
  /// Will result in error if discovery was not done during this connection.
  Future<Descriptor> writeDescriptor(
    String serviceUuid,
    String characteristicUuid,
    String descriptorUuid,
    Uint8List value, {
    String? transactionId,
  }) =>
      _manager.writeDescriptorForPeripheral(
        this,
        serviceUuid,
        characteristicUuid,
        descriptorUuid,
        value,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  /// Returns a stream of notifications/indications from [Characteristic]
  /// matching specified UUIDs.
  ///
  /// Emits [CharacteristicWithValue] for every observed change of the
  /// characteristic specified by [serviceUuid] and [characteristicUuid]
  /// If notifications are enabled they will be used in favour of indications.
  /// Optional [transactionId] could be used to cancel operation. Unsubscribing
  /// from the stream cancels monitoring.
  ///
  /// Will result in error if discovery was not done during this connection.
  Stream<CharacteristicWithValue> monitorCharacteristic(
    String serviceUuid,
    String characteristicUuid, {
    String? transactionId,
  }) =>
      _manager.monitorCharacteristicForDevice(
        this,
        serviceUuid,
        characteristicUuid,
        transactionId ?? TransactionIdGenerator.getNextId(),
      );

  @override
  String toString() {
    return 'Peripheral{\n\tname: $name, \n\tidentifier: $identifier\n}';
  }
}

/// Enum covers all possible connection state
enum PeripheralConnectionState {
  connecting,
  connected,
  disconnected,
  disconnecting
}
