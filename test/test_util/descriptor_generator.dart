import 'dart:convert';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_managers_for_classes.dart';

class DescriptorGenerator {
  ManagerForDescriptor managerForDescriptor;

  DescriptorGenerator(this.managerForDescriptor);

  Map<String, dynamic> _createRawDescriptor(int seed) => <String, dynamic>{
        "descriptorId": seed,
        "descriptorUuid": seed.toString(),
        "value": base64Encode([seed])
      };

  DescriptorWithValue create(int seed, Characteristic characteristic) =>
      DescriptorWithValue.fromJson(
        _createRawDescriptor(seed),
        characteristic,
        managerForDescriptor,
      );
}
