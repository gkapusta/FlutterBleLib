part of _internal;

mixin ScanningMixin on FlutterBLE {
  Stream<ScanResult> _scanEvents;

  void _prepareScanEventsStream() {
    _scanEvents = const EventChannel(ChannelName.scanningEvents)
        .receiveBroadcastStream()
        .handleError(
          (errorJson) => throw BleError.fromJson(jsonDecode(errorJson.details)),
          test: (error) => error is PlatformException,
        )
        .map(
          (scanResultJson) =>
              ScanResult.fromJson(jsonDecode(scanResultJson), _manager),
        );
  }

  Stream<ScanResult> startDeviceScan(
    int scanMode,
    int callbackType,
    List<String> uuids,
    bool allowDuplicates,
  ) {
    if (_scanEvents == null) {
      _prepareScanEventsStream();
    }

    StreamController<ScanResult> streamController = StreamController.broadcast(
      onListen: () => _methodChannel.invokeMethod(
        MethodName.startDeviceScan,
        <String, dynamic>{
          ArgumentName.scanMode: scanMode,
          ArgumentName.callbackType: callbackType,
          ArgumentName.uuids: uuids,
          ArgumentName.allowDuplicates: allowDuplicates,
        },
      ),
      onCancel: () => stopDeviceScan(),
    );

    streamController
        .addStream(_scanEvents, cancelOnError: true)
        .then((_) => streamController?.close());

    return streamController.stream;
  }

  Future<void> stopDeviceScan() async {
    await _methodChannel.invokeMethod(MethodName.stopDeviceScan);
    _scanEvents = null;
    return;
  }
}
