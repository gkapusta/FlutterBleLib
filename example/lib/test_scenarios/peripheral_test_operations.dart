part of test_scenarios;

typedef TestedFunction = Future<void> Function();

class PeripheralTestOperations {
  final Peripheral peripheral;
  final Logger log;
  final Logger logError;
  StreamSubscription<double>? _monitoringStreamSubscription;
  final BleManager bleManager;

  PeripheralTestOperations(
      this.bleManager, this.peripheral, this.log, this.logError);

  Future<void> connect() async {
    await _runWithErrorHandling(() async {
      log("Connecting to ${peripheral.name}");
      await peripheral.connect();
      log("Connected!");
    });
  }

  Future<void> cancelTransaction() async {
    await _runWithErrorHandling(() async {
      log("Starting operation to cancel...");
      peripheral
          .discoverAllServicesAndCharacteristics(transactionId: "test")
          .catchError((error) {
        BleError bleError = error as BleError;
        return logError("Cancelled operation caught an error: "
            "\nerror code ${bleError.errorCode.value},"
            "\nreason: ${bleError.reason}");
      });
      log("Operation to cancel started: discover all"
          " services and characteristics");

      log("Cancelling operation...");
      await bleManager.cancelTransaction("test");
      log("Operation cancelled!");
    });
  }

  Future<void> discovery() async => await _runWithErrorHandling(() async {
        await peripheral.discoverAllServicesAndCharacteristics();
        List<Service> services = await peripheral.services();
        log("PRINTING SERVICES for \n${peripheral.name}");
        services.forEach((service) => log("Found service \n${service.uuid}"));
        Service service = services.first;
        log("PRINTING CHARACTERISTICS FOR SERVICE \n${service.uuid}");

        List<Characteristic> characteristics = await service.characteristics();
        characteristics.forEach((characteristic) {
          log("${characteristic.uuid}");
        });

        log("PRINTING CHARACTERISTICS FROM \nPERIPHERAL for the same service");
        List<Characteristic> characteristicFromPeripheral =
            await peripheral.characteristics(service.uuid);
        characteristicFromPeripheral.forEach((characteristic) =>
            log("Found characteristic \n ${characteristic.uuid}"));

        //------------ descriptors
        List<Descriptor>? descriptors;

        var printDescriptors = () => descriptors?.forEach((descriptor) {
              log("Descriptor: ${descriptor.uuid}");
            });

        log("Using IR Temperature service/IR Temperature Data "
            "characteristic for following descriptor tests");
        log("PRINTING DESCRIPTORS FOR PERIPHERAL");

        descriptors = await peripheral.descriptorsForCharacteristic(
            SensorTagTemperatureUuids.temperatureService,
            SensorTagTemperatureUuids.temperatureDataCharacteristic);

        printDescriptors();
        descriptors = null;

        log("PRINTING DESCRIPTORS FOR SERVICE");
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        descriptors = await chosenService.descriptorsForCharacteristic(
            SensorTagTemperatureUuids.temperatureDataCharacteristic);

        printDescriptors();
        descriptors = null;

        List<Characteristic> temperatureCharacteristics =
            await chosenService.characteristics();
        Characteristic chosenCharacteristic = temperatureCharacteristics.first;

        log("PRINTING DESCRIPTORS FOR CHARACTERISTIC");
        descriptors = await chosenCharacteristic.descriptors();

        printDescriptors();
      });

  Future<void> testReadingRssi() async {
    await _runWithErrorHandling(() async {
      int rssi = await peripheral.rssi();
      log("rssi $rssi");
    });
  }

  Future<void> testRequestingMtu() async {
    await _runWithErrorHandling(() async {
      int requestedMtu = 79;
      log("Requesting MTU = $requestedMtu");
      int negotiatedMtu = await peripheral.requestMtu(requestedMtu);
      log("negotiated MTU $negotiatedMtu");
    });
  }

  Future<void> readCharacteristicForPeripheral() async {
    await _runWithErrorHandling(() async {
      log("Reading temperature config");
      CharacteristicWithValue readValue = await peripheral.readCharacteristic(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureDataCharacteristic);
      log("Temperature config value: \n${_convertToTemperature(readValue.value)}C");
    });
  }

  Future<void> readCharacteristicForService() async {
    await _runWithErrorHandling(() async {
      log("Reading temperature config");
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));
      CharacteristicWithValue readValue = await service.readCharacteristic(
          SensorTagTemperatureUuids.temperatureDataCharacteristic);
      log("Temperature config value: \n${_convertToTemperature(readValue.value)}C");
    });
  }

  Future<void> readCharacteristic() async {
    await _runWithErrorHandling(() async {
      log("Reading temperature config");
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));

      List<Characteristic> characteristics = await service.characteristics();
      Characteristic characteristic = characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              SensorTagTemperatureUuids.temperatureDataCharacteristic
                  .toLowerCase());

      Uint8List readValue = await characteristic.read();
      log("Temperature config value: \n${_convertToTemperature(readValue)}C");
    });
  }

  Future<void> writeCharacteristicForPeripheral() async {
    await _runWithErrorHandling(() async {
      Uint8List currentValue = await peripheral
          .readCharacteristic(SensorTagTemperatureUuids.temperatureService,
              SensorTagTemperatureUuids.temperatureConfigCharacteristic)
          .then((characteristic) => characteristic.value);

      int valueToSave;
      if (currentValue[0] == 0) {
        log("Turning on temperature update via peripheral");
        valueToSave = 1;
      } else {
        log("Turning off temperature update via peripheral");
        valueToSave = 0;
      }

      await peripheral.writeCharacteristic(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureConfigCharacteristic,
          Uint8List.fromList([valueToSave]),
          false);

      log("Written \"$valueToSave\" to temperature config");
    });
  }

  Future<void> writeCharacteristicForService() async {
    await _runWithErrorHandling(() async {
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));

      Uint8List currentValue = await service
          .readCharacteristic(
              SensorTagTemperatureUuids.temperatureConfigCharacteristic)
          .then((characteristic) => characteristic.value);

      int valueToSave;
      if (currentValue[0] == 0) {
        log("Turning on temperature update via service");
        valueToSave = 1;
      } else {
        log("Turning off temperature update via service");
        valueToSave = 0;
      }

      await service.writeCharacteristic(
          SensorTagTemperatureUuids.temperatureConfigCharacteristic,
          Uint8List.fromList([valueToSave]),
          false);

      log("Written \"$valueToSave\" to temperature config");
    });
  }

  Future<void> writeCharacteristic() async {
    await _runWithErrorHandling(() async {
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));

      List<Characteristic> characteristics = await service.characteristics();
      Characteristic characteristic = characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              SensorTagTemperatureUuids.temperatureConfigCharacteristic
                  .toLowerCase());
      Uint8List currentValue = await characteristic.read();
      int valueToSave;
      if (currentValue[0] == 0) {
        log("Turning on temperature update via characteristic");
        valueToSave = 1;
      } else {
        log("Turning off temperature update via characteristic");
        valueToSave = 0;
      }
      await characteristic.write(Uint8List.fromList([valueToSave]), false);
      log("Written \"$valueToSave\" to temperature config");
    });
  }

  Future<void> monitorCharacteristicForPeripheral() async {
    await _runWithErrorHandling(() async {
      log("Start monitoring temperature update");
      _startMonitoringTemperature(
          peripheral
              .monitorCharacteristic(
                  SensorTagTemperatureUuids.temperatureService,
                  SensorTagTemperatureUuids.temperatureDataCharacteristic,
                  transactionId: "monitor")
              .map((characteristic) => characteristic.value),
          log);
    });
  }

  Future<void> monitorCharacteristicForService() async {
    await _runWithErrorHandling(() async {
      log("Start monitoring temperature update");
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));
      _startMonitoringTemperature(
          service
              .monitorCharacteristic(
                  SensorTagTemperatureUuids.temperatureDataCharacteristic,
                  transactionId: "monitor")
              .map((characteristic) => characteristic.value),
          log);
    });
  }

  Future<void> monitorCharacteristic() async {
    await _runWithErrorHandling(() async {
      log("Start monitoring temperature update");
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));

      List<Characteristic> characteristics = await service.characteristics();
      Characteristic characteristic = characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              SensorTagTemperatureUuids.temperatureDataCharacteristic
                  .toLowerCase());

      _startMonitoringTemperature(
          characteristic.monitor(transactionId: "monitor"), log);
    });
  }

  Future<void> readWriteMonitorCharacteristicForPeripheral() async {
    await _runWithErrorHandling(() async {
      log("Test read/write/monitor characteristic on device");
      log("Start monitoring temperature");
      _startMonitoringTemperature(
        peripheral
            .monitorCharacteristic(SensorTagTemperatureUuids.temperatureService,
                SensorTagTemperatureUuids.temperatureDataCharacteristic,
                transactionId: "1")
            .map((characteristic) => characteristic.value),
        log,
      );
      log("Turning off temperature update");
      await peripheral.writeCharacteristic(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureConfigCharacteristic,
          Uint8List.fromList([0]),
          false);
      log("Turned off temperature update");

      log("Waiting one second for the reading");
      await Future.delayed(Duration(seconds: 1));

      log("Reading temperature");
      CharacteristicWithValue readValue = await peripheral.readCharacteristic(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureDataCharacteristic);
      log("Read temperature value ${_convertToTemperature(readValue.value)}C");

      log("Turning on temperature update");
      await peripheral.writeCharacteristic(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureConfigCharacteristic,
          Uint8List.fromList([1]),
          false);

      log("Turned on temperature update");

      log("Waiting 1 second for the reading");
      await Future.delayed(Duration(seconds: 1));
      log("Reading temperature");
      readValue = await peripheral.readCharacteristic(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureDataCharacteristic);
      log("Read temperature value ${_convertToTemperature(readValue.value)}C");

      log("Canceling temperature monitoring");
      await bleManager.cancelTransaction("1");
    });
  }

  Future<void> readWriteMonitorCharacteristicForService() async {
    await _runWithErrorHandling(() async {
      log("Test read/write/monitor characteristic on service");
      log("Fetching service");

      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));

      log("Start monitoring temperature");
      _startMonitoringTemperature(
        service
            .monitorCharacteristic(
                SensorTagTemperatureUuids.temperatureDataCharacteristic,
                transactionId: "2")
            .map((characteristic) => characteristic.value),
        log,
      );

      log("Turning off temperature update");
      await service.writeCharacteristic(
        SensorTagTemperatureUuids.temperatureConfigCharacteristic,
        Uint8List.fromList([0]),
        false,
      );
      log("Turned off temperature update");

      log("Waiting one second for the reading");
      await Future.delayed(Duration(seconds: 1));

      log("Reading temperature value");
      CharacteristicWithValue dataCharacteristic =
          await service.readCharacteristic(
              SensorTagTemperatureUuids.temperatureDataCharacteristic);
      log("Read temperature value ${_convertToTemperature(dataCharacteristic.value)}C");

      log("Turning on temperature update");
      await service.writeCharacteristic(
          SensorTagTemperatureUuids.temperatureConfigCharacteristic,
          Uint8List.fromList([1]),
          false);
      log("Turned on temperature update");

      log("Waiting one second for the reading");
      await Future.delayed(Duration(seconds: 1));

      log("Reading temperature value");
      dataCharacteristic = await service.readCharacteristic(
          SensorTagTemperatureUuids.temperatureDataCharacteristic);
      log("Read temperature value ${_convertToTemperature(dataCharacteristic.value)}C");
      log("Canceling temperature monitoring");
      await bleManager.cancelTransaction("2");
    });
  }

  Future<void> readWriteMonitorCharacteristic() async {
    await _runWithErrorHandling(() async {
      log("Test read/write/monitor characteristic on characteristic");

      log("Fetching service");
      Service service = await peripheral.services().then((services) =>
          services.firstWhere((service) =>
              service.uuid ==
              SensorTagTemperatureUuids.temperatureService.toLowerCase()));

      log("Fetching config characteristic");
      List<Characteristic> characteristics = await service.characteristics();
      Characteristic configCharacteristic = characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              SensorTagTemperatureUuids.temperatureConfigCharacteristic
                  .toLowerCase());
      log("Fetching data characteristic");
      Characteristic dataCharacteristic = characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              SensorTagTemperatureUuids.temperatureDataCharacteristic
                  .toLowerCase());

      log("Start monitoring temperature");
      _startMonitoringTemperature(
        dataCharacteristic.monitor(transactionId: "3"),
        log,
      );

      log("Turning off temperature update");
      await configCharacteristic.write(Uint8List.fromList([0]), false);
      log("Turned off temperature update");

      log("Waiting one second for the reading");
      await Future.delayed(Duration(seconds: 1));

      log("Reading characteristic value");
      Uint8List value = await configCharacteristic.read();
      log("Read temperature config value \n$value");

      log("Turning on temperature update");
      await configCharacteristic.write(Uint8List.fromList([1]), false);
      log("Turned on temperature update");

      log("Waiting one second for the reading");
      await Future.delayed(Duration(seconds: 1));

      log("Reading characteristic value");
      value = await configCharacteristic.read();
      log("Read temperature config value \n$value");

      log("Canceling temperature monitoring");
      await bleManager.cancelTransaction("3");
    });
  }

  Future<void> disconnect() async {
    await _runWithErrorHandling(() async {
      log("WAITING 10 SECOND BEFORE DISCONNECTING");
      await Future.delayed(Duration(seconds: 10));
      log("DISCONNECTING...");
      await peripheral.disconnectOrCancelConnection();
      log("Disconnected!");
    });
  }

  Future<void> fetchConnectedDevice() async {
    await _runWithErrorHandling(() async {
      log("Fetch connected devices with no service specified");
      List<Peripheral> peripherals = await bleManager.connectedPeripherals([]);
      peripherals.forEach((peripheral) => log("\t${peripheral.toString()}"));
      log("Device fetched");
      log("Fetch connected devices with temperature service");
      peripherals = await bleManager
          .connectedPeripherals([SensorTagTemperatureUuids.temperatureService]);
      peripherals.forEach((peripheral) => log("\t${peripheral.toString()}"));
      log("Device fetched");
    });
  }

  Future<void> fetchKnownDevice() async {
    await _runWithErrorHandling(() async {
      log("Fetch known devices with no IDs specified");
      List<Peripheral> peripherals = await bleManager.knownPeripherals([]);
      peripherals.forEach((peripheral) => log("\t${peripheral.toString()}"));
      log("Device fetched");
      log("Fetch known devices with one known device's ID specified");
      peripherals = await bleManager.knownPeripherals([peripheral.identifier]);
      peripherals.forEach((peripheral) => log("\t${peripheral.toString()}"));
      log("Device fetched");
    });
  }

  Future<void> readDescriptorForPeripheral() async =>
      _runWithErrorHandling(() async {
        log("READ DESCRIPTOR FOR PERIPHERAL");
        log("Reading value...");
        Uint8List value = await peripheral
            .readDescriptor(
              SensorTagTemperatureUuids.temperatureService,
              SensorTagTemperatureUuids.temperatureDataCharacteristic,
              SensorTagTemperatureUuids
                  .clientCharacteristicConfigurationDescriptor,
            )
            .then((descriptorWithValue) => descriptorWithValue.value);
        log("Value $value read!");
      });

  Future<void> readDescriptorForService() async =>
      _runWithErrorHandling(() async {
        log("READ DESCRIPTOR FOR SERVICE");

        log("Fetching service");
        List<Service> services = await peripheral.services();
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        log("Reading value...");
        Uint8List value = await chosenService
            .readDescriptor(
              SensorTagTemperatureUuids.temperatureDataCharacteristic,
              SensorTagTemperatureUuids
                  .clientCharacteristicConfigurationDescriptor,
            )
            .then((descriptorWithValue) => descriptorWithValue.value);
        log("Value $value read!");
      });

  Future<void> readDescriptorForCharacteristic() async =>
      _runWithErrorHandling(() async {
        log("READ DESCRIPTOR FOR CHARACTERISTIC");

        log("Fetching service");
        List<Service> services = await peripheral.services();
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        log("Fetching characteristic");
        List<Characteristic> temperatureCharacteristics =
            await chosenService.characteristics();
        Characteristic chosenCharacteristic = temperatureCharacteristics.first;

        log("Reading value...");
        Uint8List value = await chosenCharacteristic
            .readDescriptor(
              SensorTagTemperatureUuids
                  .clientCharacteristicConfigurationDescriptor,
            )
            .then((descriptorWithValue) => descriptorWithValue.value);
        log("Value $value read!");
      });

  Future<void> readDescriptor() async => _runWithErrorHandling(() async {
        log("READ DESCRIPTOR FOR DESCRIPTOR");

        log("Fetching service");
        List<Service> services = await peripheral.services();
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        log("Fetching characteristic");
        List<Characteristic> temperatureCharacteristics =
            await chosenService.characteristics();
        Characteristic chosenCharacteristic = temperatureCharacteristics.first;

        log("Fetching descriptor");
        List<Descriptor> descriptors = await chosenCharacteristic.descriptors();
        Descriptor chosenDescriptor = descriptors.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids
                .clientCharacteristicConfigurationDescriptor);

        log("Reading value...");
        Uint8List value = await chosenDescriptor.read();
        log("Value $value read!");
      });

  Future<void> writeDescriptorForPeripheral({bool enable = false}) async =>
      _runWithErrorHandling(() async {
        log("WRITE DESCRIPTOR FOR PERIPHERAL");
        log("Writing value...");
        Descriptor value = await peripheral.writeDescriptor(
          SensorTagTemperatureUuids.temperatureService,
          SensorTagTemperatureUuids.temperatureDataCharacteristic,
          SensorTagTemperatureUuids.clientCharacteristicConfigurationDescriptor,
          Uint8List.fromList([enable ? 1 : 0, 0]),
        );
        log("Descriptor $value written to!");
      });

  Future<void> writeDescriptorForService({bool enable = false}) async =>
      _runWithErrorHandling(() async {
        log("WRITE DESCRIPTOR FOR SERVICE");

        log("Fetching service");
        List<Service> services = await peripheral.services();
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        log("Writing value...");
        Descriptor value = await chosenService.writeDescriptor(
          SensorTagTemperatureUuids.temperatureDataCharacteristic,
          SensorTagTemperatureUuids.clientCharacteristicConfigurationDescriptor,
          Uint8List.fromList([enable ? 1 : 0, 0]),
        );
        log("Descriptor $value written to!");
      });

  Future<void> writeDescriptorForCharacteristic({bool enable = false}) async =>
      _runWithErrorHandling(() async {
        log("WRITE DESCRIPTOR FOR CHARACTERISTIC");

        log("Fetching service");
        List<Service> services = await peripheral.services();
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        log("Fetching characteristic");
        List<Characteristic> temperatureCharacteristics =
            await chosenService.characteristics();
        Characteristic chosenCharacteristic = temperatureCharacteristics.first;

        log("Writing value...");
        Descriptor value = await chosenCharacteristic.writeDescriptor(
          SensorTagTemperatureUuids.clientCharacteristicConfigurationDescriptor,
          Uint8List.fromList([enable ? 1 : 0, 0]),
        );
        log("Descriptor $value written to!");
      });

  Future<void> writeDescriptor({bool enable = false}) async =>
      _runWithErrorHandling(() async {
        log("WRITE DESCRIPTOR FOR DESCRIPTOR");

        log("Fetching service");
        List<Service> services = await peripheral.services();
        Service chosenService = services.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids.temperatureService.toLowerCase());

        log("Fetching characteristic");
        List<Characteristic> temperatureCharacteristics =
            await chosenService.characteristics();
        Characteristic chosenCharacteristic = temperatureCharacteristics.first;

        log("Fetching descriptor");
        List<Descriptor> descriptors = await chosenCharacteristic.descriptors();
        Descriptor chosenDescriptor = descriptors.firstWhere((elem) =>
            elem.uuid ==
            SensorTagTemperatureUuids
                .clientCharacteristicConfigurationDescriptor);

        log("Writing value...");
        await chosenDescriptor.write(
          Uint8List.fromList([enable ? 1 : 0, 0]),
        );
        log("Descriptor $chosenDescriptor written to!");
      });

  Future<void> readWriteDescriptorForPeripheral() async =>
      _runWithErrorHandling(
        () async {
          log("READ/WRITE TEST FOR PERIPHERAL");
          await readDescriptorForPeripheral();
          await writeDescriptorForPeripheral(enable: true);
          await readDescriptorForPeripheral();
          await writeDescriptorForPeripheral(enable: false);
          await readDescriptorForPeripheral();
        },
      );

  Future<void> readWriteDescriptorForService() async => _runWithErrorHandling(
        () async {
          log("READ/WRITE TEST FOR SERVICE");
          await readDescriptorForService();
          await writeDescriptorForService(enable: true);
          await readDescriptorForService();
          await writeDescriptorForService(enable: false);
          await readDescriptorForService();
        },
      );

  Future<void> readWriteDescriptorForCharacteristic() async =>
      _runWithErrorHandling(
        () async {
          log("READ/WRITE TEST FOR CHARACTERISTIC");
          await readDescriptorForCharacteristic();
          await writeDescriptorForCharacteristic(enable: true);
          await readDescriptorForCharacteristic();
          await writeDescriptorForCharacteristic(enable: false);
          await readDescriptorForCharacteristic();
        },
      );

  Future<void> readWriteDescriptor() async => _runWithErrorHandling(
        () async {
          log("READ/WRITE TEST FOR DESCRIPTOR");
          await readDescriptor();
          await writeDescriptor(enable: true);
          await readDescriptor();
          await writeDescriptor(enable: false);
          await readDescriptor();
        },
      );

  void _startMonitoringTemperature(
      Stream<Uint8List> characteristicUpdates, Function log) async {
    await _monitoringStreamSubscription?.cancel();
    _monitoringStreamSubscription =
        characteristicUpdates.map(_convertToTemperature).listen(
      (temperature) {
        log("Temperature updated: ${temperature}C");
      },
      onError: (error) {
        log("Error while monitoring characteristic \n$error");
      },
      cancelOnError: true,
    );
  }

  double _convertToTemperature(Uint8List rawTemperatureBytes) {
    const double SCALE_LSB = 0.03125;
    int rawTemp = rawTemperatureBytes[3] << 8 | rawTemperatureBytes[2];
    return ((rawTemp) >> 2) * SCALE_LSB;
  }

  Future<void> disableBluetooth() async {
    await _runWithErrorHandling(() async {
      log("Disabling radio");
      await bleManager.disableRadio();
    });
  }

  Future<void> enableBluetooth() async {
    await _runWithErrorHandling(() async {
      log("Enabling radio");
      await bleManager.enableRadio();
    });
  }

  Future<void> fetchBluetoothState() async {
    await _runWithErrorHandling(() async {
      BluetoothState bluetoothState = await bleManager.bluetoothState();
      log("Radio state: $bluetoothState");
    });
  }

  Future<void> _runWithErrorHandling(TestedFunction testedFunction) async {
    try {
      await testedFunction();
    } on BleError catch (e) {
      logError("BleError caught: ${e.errorCode.value} ${e.reason}");
    } catch (e) {
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      logError("${e.runtimeType}: $e");
    }
  }
}
