import 'dart:async';
@Timeout(const Duration(milliseconds: 500))
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_internal.dart';
import 'package:flutter_ble_lib/src/_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import './lib_core_test.mocks.dart';

import '../../json/ble_error_jsons.dart';

const flutterBleLibMethodChannelName = 'flutter_ble_lib';
const monitorCharacteristicEventChannelName =
    flutterBleLibMethodChannelName + '/monitorCharacteristic';
const mockServiceUuid = "A0C8AAC8-2C37-4CE4-9110-EA7E09704D54";
const mockCharacteristicUuid = "A56CCE6A-2178-4710-81CA-7895309A1350";
const mockCharacteristicId = 44;
const mockServiceId = 42;
const mockId = 43;
const mockTransactionId = "asdasd123asd";

@GenerateMocks([Peripheral, InternalBleManager])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FlutterBleLib bleLib;
  final peripheral = MockPeripheral();
  MethodChannel methodChannel = MethodChannel(flutterBleLibMethodChannelName);
  MethodChannel eventMethodChannel =
      MethodChannel(monitorCharacteristicEventChannelName);

  setUp(() {
    bleLib = FlutterBleLib(MockInternalBleManager());
    when(peripheral.identifier).thenReturn("4B:99:4C:34:DE:77");
    methodChannel.setMockMethodCallHandler((call) { 
      return Future.value("");
    });
    eventMethodChannel.setMockMethodCallHandler((call) { 
      return Future.value("");
    });
  });

  Future<void> _emitPlatformError(String errorJson) async {
    final serBinding = ServicesBinding.instance;
    if (serBinding == null) {
      return;
    }
    await serBinding.defaultBinaryMessenger.handlePlatformMessage(
      monitorCharacteristicEventChannelName,
      const StandardMethodCodec().encodeErrorEnvelope(
        code: "irrelevant", 
        details: errorJson
      ),
      (data) {
        print(data);
      }
    );
  }

  Future<void> _emitMonitoringEvent(String eventJson) async {
    final serBinding = ServicesBinding.instance;
    if (serBinding == null) {
      return;
    }
    await serBinding.defaultBinaryMessenger.handlePlatformMessage(
      monitorCharacteristicEventChannelName,
      const StandardMethodCodec().encodeSuccessEnvelope(eventJson),
      (data) {}
    );
  }

  Future<void> _emitStreamCompletion() async {
    final serBinding = ServicesBinding.instance;
    if (serBinding == null) {
      return;
    }
    await serBinding.defaultBinaryMessenger.handlePlatformMessage(
      monitorCharacteristicEventChannelName,
      null,
      (data) {},
    );
  }

  CharacteristicWithValueAndTransactionId createCharacteristicFromDecodedJson(
    Map<String, dynamic> decodedRoot
  ) {
    Map<String, dynamic> decodedCharacteristic = decodedRoot["characteristic"];
    String transactionId = decodedRoot["transactionId"];
    return CharacteristicWithValueAndTransactionId.fromJson(
      decodedCharacteristic,
      Service.fromJson(decodedRoot, peripheral, MockInternalBleManager()),
      MockInternalBleManager(),
    ).setTransactionId(transactionId);
  }

  Map<String, dynamic> createRawCharacteristic(
    {
    bool mockIds = false,
    int? id,
    int? serviceId,
    String? serviceUuid,
    String? characteristicUuid,
    String? transactionId,
    String base64value = ""
  }) { 
    if (mockIds) {
      serviceUuid ??= mockServiceUuid;
      serviceId ??= mockServiceId;
      characteristicUuid ??= mockCharacteristicUuid;
      id ??= mockCharacteristicId;
    }

    return <String, dynamic>{
          "serviceUuid": serviceUuid,
          "serviceId": serviceId,
          "transactionId": transactionId,
          "characteristic": <String, dynamic>{
            "characteristicUuid": characteristicUuid,
            "id": id,
            "isReadable": true,
            "isWritableWithResponse": false,
            "isWritableWithoutResponse": false,
            "isNotifiable": true,
            "isIndicatable": false,
            "value": base64value,
          }
        };
  }

  test('monitorCharacteristicForIdentifier cancels on stream error', () async {
    final mockTransId = "asdasd";

    final fut = expectLater(
      bleLib.monitorCharacteristicForIdentifier(peripheral, 123, mockTransId),
      emitsInOrder([
        emitsError(isInstanceOf<BleError>()),
        emitsDone,
      ])
    );
    await _emitPlatformError(cancellationErrorJson(mockTransId));

    await fut;
  });

  test('monitorCharacteristicForDevice cancels on stream error', () async {
    String mockTransId = "";
    final fut = expectLater(
        bleLib.monitorCharacteristicForDevice(
          peripheral,
          "serviceUuid",
          "characteristicUuid",
          mockTransId
        ),
        emitsInOrder([
          emitsError(isInstanceOf<BleError>()),
          emitsDone,
        ]));
    await _emitPlatformError(cancellationErrorJson(mockTransId));
    await fut;
  });

  test('monitorCharacteristicForService cancels on stream error', () async {
    String mockTransId = "";
    final fut = expectLater(
        bleLib.monitorCharacteristicForService(
            peripheral, 123, "characteristicUuid", mockTransId),
        emitsInOrder([
          emitsError(isInstanceOf<BleError>()),
          emitsDone,
        ]));
    await _emitPlatformError(cancellationErrorJson(mockTransId));
    await fut;
  });

  test(
      'monitorCharacteristicForIdentifier streams events with matching characteristic id and transaction id',
      () async {
    final fut = expectLater(
      bleLib.monitorCharacteristicForIdentifier(peripheral, 1, "1"),
      emitsInOrder([
        emits(
          equals(
            Uint8List.fromList([1, 0, 0, 0])
          )
        ),
        emitsDone
      ])
    );

    await _emitMonitoringEvent(
      jsonEncode(
        createRawCharacteristic(
          mockIds: true,
          id: 1, 
          transactionId: "1",
          base64value: "AQAAAA=="
        )
      )
    ); //[1,0,0,0]
    await _emitMonitoringEvent(
      jsonEncode(
        createRawCharacteristic(
          mockIds: true,
          id: 1, 
          transactionId: "2", 
          base64value: "AAEAAA=="
        )
      )
    ); //[0,1,0,0]
    await _emitMonitoringEvent(
      jsonEncode(
        createRawCharacteristic(
          mockIds: true,
          id: 2, 
          transactionId: "1", 
          base64value: "AAABAA=="
        )
      )
    ); //[0,0,1,0]
    await _emitMonitoringEvent(
      jsonEncode(
        createRawCharacteristic(
          mockIds: true,
          id: 2,
          transactionId: "2",
          base64value: "AAAAAQ=="
        )
      )
    ); //[0,0,0,1]
    await _emitStreamCompletion();
    await fut;
  });

  test(
      'monitorCharacteristicForDevice streams events with matching characteristic uuid, service uuid and transaction id',
      () async {
    final expected = 
      createRawCharacteristic(
        mockIds: true,
        serviceUuid: "serviceUuid",
        characteristicUuid: "characteristicUuid",
        transactionId: "1"
      );
    final fut = expectLater(
      bleLib.monitorCharacteristicForDevice(
        peripheral, 
        "serviceUuid", 
        "characteristicUuid", 
        "1"
      ),
      emitsInOrder([
        emits(
          equals(
            createCharacteristicFromDecodedJson(expected)
          )
        ),
        emitsDone
      ])
    );
    final valid =
      createRawCharacteristic(
        mockIds: true,
        serviceUuid: "serviceUuid",
        characteristicUuid: "characteristicUuid",
        transactionId: "1"
      );
    final invalid1 =
      createRawCharacteristic(
        mockIds: true,
        serviceUuid: "serviceUuid",
        characteristicUuid: "fakeUuid",
        transactionId: "1"
      );
    final invalid2 =
      createRawCharacteristic(
        mockIds: true,
        serviceUuid: "fakeUuid",
        characteristicUuid: "characteristicUuid",
        transactionId: "1"
      );
    final invalid3 = 
      createRawCharacteristic(
        mockIds: true,
        serviceUuid: "serviceUuid",
        characteristicUuid: "characteristicUuid",
        transactionId: "2"
      );
    expect(expected, equals(valid));
    expect(expected, isNot(equals(invalid1)));
    expect(expected, isNot(equals(invalid2)));
    expect(expected, isNot(equals(invalid3)));

    await _emitMonitoringEvent(jsonEncode(valid));
    await _emitMonitoringEvent(jsonEncode(invalid1));
    await _emitMonitoringEvent(jsonEncode(invalid2));
    await _emitMonitoringEvent(jsonEncode(invalid3));
    await _emitStreamCompletion();
    await fut;
  });

  test(
      'monitorCharacteristicForService streams events with matching service id, characteristic uuid and transaction id',
      () async {
    final fut = expectLater(
        bleLib.monitorCharacteristicForService(
            peripheral, 1, "characteristicUuid", "1"),
        emitsInOrder([
          emits(equals(
              createCharacteristicFromDecodedJson(createRawCharacteristic(
            mockIds: true,
            serviceId: 1,
            characteristicUuid: "characteristicUuid",
            transactionId: "1",
          )))),
          emitsDone
        ]));

    await _emitMonitoringEvent(jsonEncode(createRawCharacteristic(
        mockIds: true,
        serviceId: 1,
        characteristicUuid: "characteristicUuid",
        transactionId: "1")));
    await _emitMonitoringEvent(jsonEncode(createRawCharacteristic(
        mockIds: true,
        serviceId: 1, characteristicUuid: "fakeUuid", transactionId: "1")));
    await _emitMonitoringEvent(jsonEncode(createRawCharacteristic(
        mockIds: true,
        serviceId: 2,
        characteristicUuid: "characteristicUuid",
        transactionId: "1")));
    await _emitMonitoringEvent(jsonEncode(createRawCharacteristic(
        mockIds: true,
        serviceId: 1,
        characteristicUuid: "characteristicUuid",
        transactionId: "2")));
    await _emitStreamCompletion();
    await fut;
  });

  test(
    "Monitoring transaction is cancelled after unsubscribing all subscribers from monitoring stream",
    () async {
      //given
      Stream<Uint8List> monitoringStream =
          bleLib.monitorCharacteristicForIdentifier(peripheral, 1, "1");
      StreamSubscription subscription = monitoringStream.listen((_) {});

      StreamSubscription subscription1 = monitoringStream.listen((_) {});

      int calledCount = 0;
      methodChannel.setMockMethodCallHandler((call) {
        if (call.method == MethodName.cancelTransaction &&
            call.arguments[ArgumentName.transactionId] == "1") {
          calledCount++;
        }
        return Future.value("");
      });

      //when
      await subscription.cancel();
      await subscription1.cancel();

      //then
      expect(calledCount, 1);
    },
  );

  test(
    "Monitoring transaction is cancelled after unsubscribing the only subscriber from monitoring stream",
    () async {
      //given
      Stream<Uint8List> monitoringStream =
          bleLib.monitorCharacteristicForIdentifier(peripheral, 1, "1");
      StreamSubscription subscription = monitoringStream.listen((_) {});

      int calledCount = 0;
      methodChannel.setMockMethodCallHandler((call) {
        if (call.method == MethodName.cancelTransaction &&
            call.arguments[ArgumentName.transactionId] == "1") {
          calledCount++;
        }
        return Future.value("");
      });

      //when
      await subscription.cancel();

      //then
      expect(calledCount, 1);
    },
  );

  test(
    "Monitoring transaction is not cancelled after unsubscribing only one subscriber from monitoring stream",
    () async {
      //given
      Stream<Uint8List> monitoringStream =
          bleLib.monitorCharacteristicForIdentifier(peripheral, 1, "1");
      StreamSubscription subscription = monitoringStream.listen((_) {});

      monitoringStream.listen((_) {});

      int calledCount = 0;
      methodChannel.setMockMethodCallHandler((call) {
        if (call.method == MethodName.cancelTransaction &&
            call.arguments[ArgumentName.transactionId] == "1") {
          calledCount++;
        }
        return Future.value("");
      });

      //when
      await subscription.cancel();

      //then
      expect(calledCount, 0);
    },
  );
}
