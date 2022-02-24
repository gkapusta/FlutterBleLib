part of _internal;

abstract class FlutterBLE {
  final InternalBleManager _manager;

  FlutterBLE._(this._manager);

  final MethodChannel _methodChannel =
      const MethodChannel(ChannelName.flutterBleLib);

  Future<void> cancelTransaction(String transactionId) async {
    await _methodChannel.invokeMethod(MethodName.cancelTransaction,
        <String, String>{ArgumentName.transactionId: transactionId});
    return;
  }
}

class FlutterBleLib extends FlutterBLE
    with
        DeviceConnectionMixin,
        DiscoveryMixin,
        ScanningMixin,
        LogLevelMixin,
        RssiMixin,
        MtuMixin,
        BluetoothStateMixin,
        DevicesMixin,
        CharacteristicsMixin,
        DescriptorsMixin {
  final Stream<dynamic> _restoreStateEvents =
      const EventChannel(ChannelName.stateRestoreEvents)
          .receiveBroadcastStream();

  FlutterBleLib(InternalBleManager manager) : super._(manager);

  Future<List<Peripheral>> restoredState() async { 
    final peripherals = await _restoreStateEvents
      .map(
        (jsonString) {
          if (jsonString == null || 
              jsonString is String == false) {
            return null;
          }
          final restoredPeripheralsJson =
              (jsonDecode(jsonString) as List<dynamic>)
              .cast<Map<String, dynamic>>();
          return restoredPeripheralsJson
              .map((peripheralJson) =>
                  Peripheral.fromJson(peripheralJson, _manager))
              .toList();
          
        },
      )
      .take(1)
      .single;
    return peripherals ?? <Peripheral>[];
  }

  Future<bool> isClientCreated() =>
    _methodChannel.invokeMethod<bool>(MethodName.isClientCreated)
      .then((value) => value!);

  Future<void> createClient(String? restoreStateIdentifier) async {
    await _methodChannel.invokeMethod(MethodName.createClient, <String, String?>{
      ArgumentName.restoreStateIdentifier: restoreStateIdentifier
    });
  }

  Future<void> destroyClient() async {
    await _methodChannel.invokeMethod(MethodName.destroyClient);
  }
}
