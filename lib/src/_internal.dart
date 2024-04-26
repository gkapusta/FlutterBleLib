library _internal;

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_constants.dart';
import 'package:flutter_ble_lib/src/_containers.dart';
import 'package:flutter_ble_lib/src/util/_transaction_id_generator.dart';
import 'package:flutter_ble_lib/src/util/_transformers.dart';

import '_managers_for_classes.dart';

part 'base_entities.dart';
part 'bridge/bluetooth_state_mixin.dart';
part 'bridge/characteristics_mixin.dart';
part 'bridge/descriptors_mixin.dart';
part 'bridge/device_connection_mixin.dart';
part 'bridge/device_rssi_mixin.dart';
part 'bridge/devices_mixin.dart';
part 'bridge/discovery_mixin.dart';
part 'bridge/lib_core.dart';
part 'bridge/log_level_mixin.dart';
part 'bridge/mtu_mixin.dart';
part 'bridge/scanning_mixin.dart';
part 'internal_ble_manager.dart';
