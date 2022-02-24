part of _internal;

mixin DeviceConnectionMixin on FlutterBLE {
  final Stream<dynamic> _peripheralConnectionStateChanges =
      const EventChannel(ChannelName.connectionStateChangeEvents)
          .receiveBroadcastStream();

  Future<void> connectToPeripheral(
    String deviceIdentifier, 
    bool isAutoConnect,
    int requestMtu, 
    bool refreshGatt,
    Duration? timeout
  ) async {
    return await _methodChannel.invokeMethod(
      MethodName.connectToDevice,
      <String, dynamic>{
        ArgumentName.deviceIdentifier: deviceIdentifier,
        ArgumentName.isAutoConnect: isAutoConnect,
        ArgumentName.requestMtu: requestMtu,
        ArgumentName.refreshGatt: refreshGatt,
        ArgumentName.timeoutMillis: timeout?.inMilliseconds
      },
    ).catchError(
      (errorJson) => Future.error(
        BleError.fromJson(jsonDecode(errorJson.details)),
      ),
    );
  }

  Stream<PeripheralConnectionState> observePeripheralConnectionState(
      String identifier, bool emitCurrentValue) {
    final controller = StreamController<PeripheralConnectionState>(
      onListen: () => _methodChannel.invokeMethod(
        MethodName.observeConnectionState,
        <String, dynamic>{
          ArgumentName.deviceIdentifier: identifier,
          ArgumentName.emitCurrentValue: emitCurrentValue,
        },
      ).catchError(
        (errorJson) => throw BleError.fromJson(jsonDecode(errorJson.details)),
      ),
    );

    final sourceStream = _peripheralConnectionStateChanges
        .map((jsonString) =>
            ConnectionStateContainer.fromJson(jsonDecode(jsonString)))
        .where((connectionStateContainer) =>
            connectionStateContainer.peripheralIdentifier == identifier)
        .map((connectionStateContainer) =>
            connectionStateContainer.connectionState)
        .map((connectionStateString) {
      switch (connectionStateString.toLowerCase()) {
        case NativeConnectionState.connected:
          return PeripheralConnectionState.connected;
        case NativeConnectionState.connecting:
          return PeripheralConnectionState.connecting;
        case NativeConnectionState.disconnected:
          return PeripheralConnectionState.disconnected;
        case NativeConnectionState.disconnecting:
          return PeripheralConnectionState.disconnecting;
        default:
          throw FormatException(
            'Unrecognized value of device connection state. Value: $connectionStateString',
          );
      }
    });

    controller
        .addStream(
          sourceStream,
          cancelOnError: true,
        )
        .then((value) => controller.close());

    return controller.stream;
  }

  Future<bool> isPeripheralConnected(String peripheralIdentifier) async {
    return await _methodChannel
        .invokeMethod(MethodName.isDeviceConnected, <String, dynamic>{
      ArgumentName.deviceIdentifier: peripheralIdentifier,
    }).catchError(
      (errorJson) {
        if (errorJson is MissingPluginException) {
          return Future.error(errorJson);
        }
        return Future.error(
          BleError.fromJson(jsonDecode(errorJson.details))
        );
      }
    );
  }

  Future<void> disconnectOrCancelPeripheralConnection(
      String peripheralIdentifier) async {
    return await _methodChannel
        .invokeMethod(MethodName.cancelConnection, <String, dynamic>{
      ArgumentName.deviceIdentifier: peripheralIdentifier,
    }).catchError(
      (errorJson) => Future.error(
        BleError.fromJson(jsonDecode(errorJson.details)),
      ),
    );
  }
}
