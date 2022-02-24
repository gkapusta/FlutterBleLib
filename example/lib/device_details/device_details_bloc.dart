import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib_example/model/ble_device.dart';
import 'package:flutter_ble_lib_example/repository/device_repository.dart';
import 'package:flutter_ble_lib_example/test_scenarios/test_scenarios.dart';
import 'package:rxdart/rxdart.dart';

import '../model/ble_device.dart';
import '../repository/device_repository.dart';

class DeviceDetailsBloc {
  final BleManager _bleManager;
  final DeviceRepository _deviceRepository;

  late final BleDevice _bleDevice;

  BehaviorSubject<PeripheralConnectionState> _connectionStateController;

  ValueStream<PeripheralConnectionState> get connectionState =>
      _connectionStateController.stream;

  Subject<List<DebugLog>> _logsController;

  Stream<List<DebugLog>> get logs => _logsController.stream;

  Stream<Null?> get disconnectedDevice => _deviceRepository.pickedDevice
      .skipWhile((bleDevice) => bleDevice != null).cast<Null>();

  List<DebugLog> _logs = [];
  late Logger log;
  late Logger logError;

  DeviceDetailsBloc({
    DeviceRepository? deviceRepository, 
    BleManager? bleManager
  }) 
  : _deviceRepository = deviceRepository ?? DeviceRepository(),
    _bleManager = bleManager ?? BleManager(),
    _connectionStateController =
      BehaviorSubject<PeripheralConnectionState>.seeded(
        PeripheralConnectionState.disconnected
      ),
    _logsController = PublishSubject<List<DebugLog>>() {
    _bleDevice = _deviceRepository.pickedDevice.value!;

    log = (text) {
      var now = DateTime.now();
      _logs.insert(
          0,
          DebugLog(
            '${now.hour}:${now.minute}:${now.second}.${now.millisecond}',
            text,
          ));
      Fimber.d(text);
      _logsController.add(_logs);
    };

    logError = (text) {
      _logs.insert(0, DebugLog(DateTime.now().toString(), "ERROR: $text"));
      Fimber.e(text);
      _logsController.add(_logs);
    };
  }

  void init() {
    Fimber.d("init bloc");
    _bleManager.stopPeripheralScan();
  }

  Future<void> disconnect() async {
    _clearLogs();
    disconnectManual();
    return _deviceRepository.pickDevice(null);
  }

  Future<void> disconnectManual() async {
    _clearLogs();
    final bleDevice = _bleDevice;
    if (await bleDevice.peripheral.isConnected()) {
      log("DISCONNECTING...");
      await bleDevice.peripheral.disconnectOrCancelConnection();
    }
    log("Disconnected!");
  }

  void readRssi() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .testReadingRssi();
  }

  void discovery() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .discovery();
  }

  void fetchConnectedDevices() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .fetchConnectedDevice();
  }

  void fetchKnownDevices() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .fetchKnownDevice();
  }

  void readCharacteristicForPeripheral() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .readCharacteristicForPeripheral();
  }

  void readCharacteristicForService() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .readCharacteristicForService();
  }

  void readCharacteristicDirectly() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .readCharacteristic();
  }

  void writeCharacteristicForPeripheral() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .writeCharacteristicForPeripheral();
  }

  void writeCharacteristicForService() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .writeCharacteristicForService();
  }

  void writeCharacteristicDirectly() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .writeCharacteristic();
  }

  void monitorCharacteristicForPeripheral() {
    _clearLogs();
      PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
          .monitorCharacteristicForPeripheral();
  }

  void monitorCharacteristicForService() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .monitorCharacteristicForService();
  }

  void monitorCharacteristicDirectly() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .monitorCharacteristic();
  }

  void disableBluetooth() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .disableBluetooth();
  }

  void enableBluetooth() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .enableBluetooth();
  }

  void fetchBluetoothState() {
    _clearLogs();
    PeripheralTestOperations(_bleManager, _bleDevice.peripheral, log, logError)
        .fetchBluetoothState();
  }

  Future<void> connect() async {
    _clearLogs();
    var peripheral = _bleDevice.peripheral;

    peripheral
        .observeConnectionState(
            emitCurrentValue: true, completeOnDisconnect: true)
        .listen((connectionState) {
      log('Observed new connection state: \n$connectionState');
      _connectionStateController.add(connectionState);
    });

    try {
      log("Connecting to ${peripheral.name}");
      await peripheral.connect();
      log("Connected!");
    } on BleError catch (e) {
      logError(e.toString());
    }
  }

  void dispose() async {
    await _connectionStateController.drain();
    _connectionStateController.close();
  }

  void _connectTo(BleDevice bleDevice) async {
    log("Fetching log level");
    LogLevel logLevel = await _bleManager.logLevel();
    log("Current log level $logLevel");

    log("Setting log level to debug");
    await _bleManager.setLogLevel(LogLevel.debug);
    log("Set log level to debug");

    log("Fetching log level");
    logLevel = await _bleManager.logLevel();
    log("Current log level $logLevel");

    var peripheral = bleDevice.peripheral;
    peripheral
        .observeConnectionState(emitCurrentValue: true)
        .listen((connectionState) {
      log('Observed new connection state: \n$connectionState');
      _connectionStateController.add(connectionState);
    });

    SensorTagTestScenario(_bleManager, peripheral, log, logError)
        .runTestScenario();
  }

  void startAutoTest() {
    _clearLogs();

    Fimber.d("got bleDevice: $_bleDevice");
    _bleDevice.peripheral.isConnected().then((isConnected) {
      Fimber.d('The device is connected: $isConnected');
      if (!isConnected) {
        _connectTo(_bleDevice);
      }
    }).catchError((error) {
      logError('Connection problem: ${error.toString()}');
    });
  }

  void _clearLogs() {
    _logs = [];
    _logsController.add(_logs);
  }
}

class DebugLog {
  String time;
  String content;

  DebugLog(this.time, this.content);
}
