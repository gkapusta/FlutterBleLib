/// Library for handling Bluetooth Low Energy functionality.
///
/// The library is organised around a few base entities, which are:
/// - [BleManager]
/// - [Peripheral]
/// - [Service]
/// - [Characteristic]
/// - [Descriptor]
///
/// You have to create an instance of [BleManager] and initialise underlying
/// native resources. Using that instance you then obtain an instance of
/// [Peripheral], which can be used to run operations on the corresponding
/// peripheral.
///
/// All operations passing the Dart-native bridge are asynchronous,
/// hence all operations in the plugin return either [Future] or [Stream].
///
/// The library handles scanning for peripherals, connecting to peripherals,
/// service discovery process on peripherals, manipulating characteristics
/// and descriptors.
///
/// Bonding is handled transparently by the platform's operating system.
///
/// You can also listen to changes of Bluetooth adapter's state.
///
/// ```dart
/// BleManager bleManager = BleManager();
/// await bleManager.createClient(); //ready to go!
/// //your BLE logic
/// bleManager.destroyClient(); //remember to release native resources when you're done!
/// ```
///
/// For more samples refer to specific classes.
library flutter_ble_lib;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_ble_lib/src/_internal.dart';
import 'package:flutter_ble_lib/src/_managers_for_classes.dart';
import 'package:flutter_ble_lib/src/util/_transaction_id_generator.dart';

part 'ble_manager.dart';
part 'characteristic.dart';
part 'descriptor.dart';
part 'error/ble_error.dart';
part 'peripheral.dart';
part 'scan_result.dart';
part 'service.dart';
