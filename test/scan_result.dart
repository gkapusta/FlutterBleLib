import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Test manufacturer data deserialization:", () {
    void testManufacturerDataDeserialization(Uint8List manufacturerData) {
      test("$manufacturerData is deserialized correctly", () {
        //given
        String serializedScanResult =
            _createJsonScanResult(manufacturerData: manufacturerData);

        //when
        ScanResult scanResult =
            ScanResult.fromJson(jsonDecode(serializedScanResult), null);

        //then
        expect(scanResult.advertisementData.manufacturerData,
            equals(manufacturerData));
      });
    }

    testManufacturerDataDeserialization(Uint8List.fromList([0, 1, 2]));
    testManufacturerDataDeserialization(Uint8List.fromList([255, 255, 255]));
    testManufacturerDataDeserialization(null);
  });

  group("Test service data deserialization", () {
    void testServiceDataDeserialization(Map<String, Uint8List> serviceData) {
      test("$serviceData is deserialized correctly", () {
        //given
        String serializedScanResult =
            _createJsonScanResult(serviceData: serviceData);

        //when
        ScanResult scanResult =
            ScanResult.fromJson(jsonDecode(serializedScanResult), null);

        //then
        expect(scanResult.advertisementData.serviceData, equals(serviceData));
      });
    }

    testServiceDataDeserialization({
      "uuid1": Uint8List.fromList([0, 1, 2]),
      "uuid2": Uint8List.fromList([0, 0, 0, 0, 0]),
    });

    testServiceDataDeserialization(null);
    testServiceDataDeserialization({});
  });
}

String _createJsonScanResult({
  String id = "valid id",
  String name = "Valid name",
  int rssi = -60,
  bool isConnectable = true,
  List<String> overflowServiceUuids,
  Uint8List manufacturerData,
  Map<String, Uint8List> serviceData,
  List<String> serviceUuids,
  String localName,
  int txPowerLevel,
  List<String> solicitedServiceUuids,
}) {
  String serializedManufacturerData;
  if (manufacturerData != null) {
    serializedManufacturerData = "\"${base64Encode(manufacturerData)}\"";
  } else {
    serializedManufacturerData = "null";
  }

  return "{"
      "\"id\": \"$id\","
      "\"name\": \"$name\","
      "\"rssi\": $rssi,"
      "\"isConnectable\": $isConnectable,"
      "\"overflowServiceUuids\": ${_jsonizeList(overflowServiceUuids)},"
      "\"manufacturerData\": $serializedManufacturerData,"
      "\"serviceData\": ${_jsonizeMap(serviceData)},"
      "\"serviceUuids\": ${_jsonizeList(serviceUuids)},"
      "\"localName\": \"$localName\","
      "\"txPowerLevel\": $txPowerLevel,"
      "\"solicitedServiceUuids\": ${_jsonizeList(solicitedServiceUuids)}}";
}

String _jsonizeList(List<String> list) {
  if (list == null) {
    return "null";
  } else {
    String result = "[";
    for (int i = 0; i < list.length; i++) {
      result += list[i];
      if (i < list.length - 1) {
        result += ",";
      }
    }
    result += "]";
    return result;
  }
}

String _jsonizeMap(Map<String, Uint8List> map) {
  if (map == null) {
    return "null";
  } else {
    String result = "{";
    List<MapEntry<String, Uint8List>> entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      result += "\"${entries[i].key}\": \"${base64Encode(entries[i].value)}\"";
      if (i < entries.length - 1) {
        result += ",";
      }
    }
    result += "}";
    return result;
  }
}
