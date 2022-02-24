part of flutter_ble_lib;

/// Callback used to inform about peripherals restored by the system.
///
/// iOS-specific.
typedef RestoreStateAction = Function(List<Peripheral> peripherals);

/// Level of details library is to output in logs.
enum LogLevel { none, verbose, debug, info, warning, error }

/// Entry point for library operations, handling allocation and deallocation
/// of underlying native resources and obtaining [Peripheral] instances.
///
/// The class is a singleton, so there's no need to keep the reference to
/// the object in one's code.
///
/// Initialising/deinitialising native clients:
/// ```dart
/// BleManager bleManager = BleManager();
/// await bleManager.createClient(); //ready to go!
/// //your BLE logic
/// bleManager.destroyClient(); //remember to release native resources when they're no longer needed
/// ```
///
/// Obtaining [Peripheral]:
/// ```dart
/// bleManager.startPeripheralScan().listen((scanResult) {
///  //Scan one peripheral and stop scanning
///  print("Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
///  bleManager.stopPeripheralScan(); // stops the scan
///});
///```
abstract class BleManager {
  static BleManager? _instance;

  factory BleManager() {
    var instance = _instance;
    if (instance == null) {
      instance = InternalBleManager();
      _instance = instance;
    }

    return instance;
  }

  /// Cancels transaction's return, resulting in [BleError] with
  /// [BleError.errorCode] set to [BleErrorCode.operationCancelled] being returned
  /// from transaction's Future.
  ///
  /// The operation might be cancelled if it hadn't yet started or be run
  /// normally, eg. writing to
  /// characteristic, but you can dismiss awaiting for the result if,
  /// for example, the result is no longer useful due to user's actions.
  Future<void> cancelTransaction(String transactionId);

  /// Checks whether the native client exists.
  Future<bool> isClientCreated();

  /// Allocates native resources.
  ///
  /// [restoreStateIdentifier] and [restoreStateAction] are iOS-specific.
  ///
  /// Must return before any other operation can be called.
  ///
  /// ```dart
  /// await BleManager().createClient();
  /// ```
  Future<void> createClient({
    String? restoreStateIdentifier,
    RestoreStateAction? restoreStateAction,
  });

  /// Frees native resources.
  ///
  /// After calling this method you must call again [createClient()] before
  /// any BLE operation.
  Future<void> destroyClient();

  /// Starts scanning for peripherals.
  ///
  /// Arguments [scanMode] and [callbackType] are Android-only,
  /// while [allowDuplicates] is iOS-only. Note that [allowDuplicates] set to
  /// false will only result in slower refresh rate for unique peripheral's
  /// advertisement data, not dismissal of it after receiving the initial one.
  /// Refer to each platform's own documentation for more detailed information.
  ///
  /// [uuids] is used to filter scan results to those whose advertised service
  /// match either of the specified UUIDs.
  ///
  /// ```dart
  /// bleManager.startPeripheralScan().listen((scanResult) {
  ///   //Scan one peripheral and stop scanning
  ///   print("Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
  ///   bleManager.stopPeripheralScan();
  /// });
  /// ```
  Stream<ScanResult> startPeripheralScan({
    int scanMode = ScanMode.lowPower,
    int callbackType = CallbackType.allMatches,
    List<String> uuids = const [],
    bool allowDuplicates = false,
  });

  /// Finishes the scan operation on the device.
  Future<void> stopPeripheralScan();

  /// Sets specified [LogLevel].
  ///
  /// This sets log level for both Dart and native platform.
  Future<void> setLogLevel(LogLevel logLevel);

  /// Returns current [LogLevel].
  Future<LogLevel> logLevel();

  /// Enables Bluetooth on Android; NOOP on iOS.
  ///
  /// Passing optional [transactionId] lets you discard the result of this
  /// operation before it is finished.
  Future<void> enableRadio({String transactionId});

  /// Disables Bluetooth on Android; NOOP on iOS.
  ///
  /// Passing optional [transactionId] lets you discard the result of this
  /// operation before it is finished.
  Future<void> disableRadio({String transactionId});

  /// Returns current state of the Bluetooth adapter.
  Future<BluetoothState> bluetoothState();

  /// Returns a stream of changes to the state of the Bluetooth adapter.
  ///
  /// By default starts the stream with the current state, but this can
  /// overridden by passing `false` as [emitCurrentValue].
  Stream<BluetoothState> observeBluetoothState({bool emitCurrentValue = true});

  /// Returns a list of [Peripheral]: on iOS known to system, on Android
  /// known to the library.
  ///
  /// If [peripheralIdentifiers] is empty, this will return an empty list.
  Future<List<Peripheral>> knownPeripherals(List<String> peripheralIdentifiers);

  /// Returns a list of [Peripheral]: on iOS connected and known to system,
  /// on Android connected and known to the library.
  ///
  /// If [serviceUUIDs] is empty, this will return an empty list.
  Future<List<Peripheral>> connectedPeripherals(List<String> serviceUUIDs);

  /// Creates a peripheral which may not exist or be available. Since the
  /// [peripheralId] might be a UUID or a MAC address,
  /// depending on the platform, its format is not validated.
  ///
  /// On iOS [peripheralId] is unique for a particular device
  /// and will not be recognized on any different device.
  /// On Android [peripheralId] scanned on one  device may or may not be
  /// recognized on a different Android device depending on peripheral’s
  /// implementation and changes in future OS releases.
  Peripheral createUnsafePeripheral(String peripheralId, {String? name});
}

/// State of the Bluetooth Adapter.
enum BluetoothState {
  UNKNOWN,
  UNSUPPORTED,
  UNAUTHORIZED,
  POWERED_ON,
  POWERED_OFF,
  RESETTING,
}

/// Mode of scan for peripherals - Android only.
///
/// See [Android documentation](https://developer.android.com/reference/android/bluetooth/le/ScanSettings) for more information.
abstract class ScanMode {
  static const int opportunistic = -1;
  static const int lowPower = 0;
  static const int balanced = 1;
  static const int lowLatency = 2;
}

/// Type of scan for peripherals callback - Android only.
///
/// See [Android documentation](https://developer.android.com/reference/android/bluetooth/le/ScanSettings) for more information.
abstract class CallbackType {
  static const int allMatches = 1;
  static const int firstMatch = 2;
  static const int matchLost = 4;
}
