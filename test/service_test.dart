import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_managers_for_classes.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';

import './service_test.mocks.dart';
import 'test_util/characteristic_generator.dart';
import 'test_util/descriptor_generator.dart';

@GenerateMocks([
  Peripheral,
  ManagerForService,
  ManagerForDescriptor,
  CharacteristicWithValue,
  DescriptorWithValue
])
void main() {
  final peripheral = MockPeripheral();
  when(peripheral.toString()).thenReturn("mocked peripheral toString()");
  when(peripheral.identifier).thenReturn("mocked peripheral id");
  final managerForService = MockManagerForService();
  when(
    managerForService.readCharacteristicForService(any, any, any, any)
  ).thenAnswer(
    (_) async => MockCharacteristicWithValue()
  );
  when(
    managerForService.readDescriptorForService(any, any, any, any)
  ).thenAnswer(
    (_) async => MockDescriptorWithValue()
  );
  when(
    managerForService.writeCharacteristicForService(any, any, any, any, any, any)
  ).thenAnswer(
    (_) async => MockCharacteristicWithValue()
  );
  when(
    managerForService.writeDescriptorForService(any, any, any, any, any)
  ).thenAnswer(
    (_) async => MockDescriptorWithValue()
  );
  when(
    managerForService.monitorCharacteristicForService(any, any, any, any)
  ).thenAnswer(
    (_) => Stream.value(MockCharacteristicWithValue())
  );
  final managerForCharacteristic =
      MockManagerForCharacteristic();
  final managerForDescriptor = MockManagerForDescriptor();
  final characteristicGenerator =
      CharacteristicGenerator(managerForCharacteristic);
  final descriptorGenerator =
      DescriptorGenerator(managerForDescriptor);

  Service service = Service.fromJson({
    "serviceId": 1,
    "serviceUuid": "testUuid",
  }, peripheral, managerForService);

  CharacteristicWithValue createCharacteristic(int seed) =>
      characteristicGenerator.create(seed, service);

  DescriptorWithValue createDescriptor(int seed) =>
      descriptorGenerator.create(seed, createCharacteristic(seed));

  tearDown(() {
    [
      peripheral,
      managerForService,
      managerForCharacteristic,
      managerForDescriptor,
    ].forEach(clearInteractions);
  });

  test("characteristics returns characteristics provided by manager", () async {
    //given
    when(managerForService.characteristicsForService(service))
        .thenAnswer((_) => Future.value([
              createCharacteristic(0),
              createCharacteristic(1),
              createCharacteristic(2),
            ]));

    //when
    var characteristics = await service.characteristics();

    //then
    expect(
        characteristics,
        equals([
          createCharacteristic(0),
          createCharacteristic(1),
          createCharacteristic(2),
        ]));
  });

  test(
      "descriptorsForCharacteristic returns characteristics provided by manager",
      () async {
    //given
    when(managerForService.descriptorsForService(service, "123"))
        .thenAnswer((_) => Future.value([
              createDescriptor(0),
              createDescriptor(1),
              createDescriptor(2),
            ]));

    //when
    var descriptors = await service.descriptorsForCharacteristic("123");

    //then
    expect(
        descriptors,
        equals([
          createDescriptor(0),
          createDescriptor(1),
          createDescriptor(2),
        ]));
  });

  test("readCharacteristic returns expected characteristic", () async {
    //given
    when(managerForService.readCharacteristicForService(
            peripheral, service, "123", "a456"))
        .thenAnswer((_) => Future.value(createCharacteristic(0)));

    //when
    var characteristic =
        await service.readCharacteristic("123", transactionId: "a456");

    //then
    expect(characteristic, equals(createCharacteristic(0)));
  });

  test("readCharacteristic reads characteristic using manager", () {
    //when
    service.readCharacteristic("123", transactionId: "a456");

    //then
    verify(
      managerForService.readCharacteristicForService(
          peripheral, service, "123", "a456"),
    );
  });

  test(
      "readCharacteristic reads characteristic with generated transactionId using manager",
      () {
    //when
    service.readCharacteristic("123", transactionId: null);

    //then
    verify(
      managerForService.readCharacteristicForService(
          peripheral, service, "123", argThat(isNotNull)),
    );
  });

  test("readDescriptor returns expected descriptor", () async {
    //given
    when(managerForService.readDescriptorForService(
            service, "123", "456", "a789"))
        .thenAnswer((_) => Future.value(createDescriptor(0)));

    //when
    var characteristic =
        await service.readDescriptor("123", "456", transactionId: "a789");

    //then
    expect(characteristic, equals(createDescriptor(0)));
  });

  test("readDescriptor reads descriptor using manager", () {
    //when
    service.readDescriptor("123", "456", transactionId: "a789");

    //then
    verify(
      managerForService.readDescriptorForService(service, "123", "456", "a789"),
    );
  });

  test(
      "readDescriptor reads descriptor with generated transactionId using manager",
      () {
    //when
    service.readDescriptor("123", "456", transactionId: null);

    //then
    verify(
      managerForService.readDescriptorForService(
          service, "123", "456", argThat(isNotNull)),
    );
  });

  test("writeCharacteristic returns expected characteristic", () async {
    //given
    when(managerForService.writeCharacteristicForService(peripheral, service,
            "123", Uint8List.fromList([1, 2, 3, 4]), false, "a456"))
        .thenAnswer((_) => Future.value(createCharacteristic(0)));

    //when
    var characteristic = await service.writeCharacteristic(
      "123",
      Uint8List.fromList([1, 2, 3, 4]),
      false,
      transactionId: "a456",
    );

    //then
    expect(characteristic, equals(createCharacteristic(0)));
  });

  test("writeCharacteristic writes characteristic using manager", () {
    //when
    service.writeCharacteristic("123", Uint8List.fromList([1, 2, 3, 4]), false,
        transactionId: "a456");

    //then
    verify(
      managerForService.writeCharacteristicForService(peripheral, service,
          "123", Uint8List.fromList([1, 2, 3, 4]), false, "a456"),
    );
  });

  test(
      "writeCharacteristic writes characteristic with generated transactionId using manager",
      () {
    //when
    service.writeCharacteristic("123", Uint8List.fromList([1, 2, 3, 4]), false,
        transactionId: null);

    //then
    verify(
      managerForService.writeCharacteristicForService(peripheral, service,
          "123", Uint8List.fromList([1, 2, 3, 4]), false, argThat(isNotNull)),
    );
  });

  test("writeDescriptor returns expected descriptor", () async {
    //given
    when(managerForService.writeDescriptorForService(
            service, "123", "456", Uint8List.fromList([1, 2, 3, 4]), "a789"))
        .thenAnswer((_) => Future.value(createDescriptor(0)));

    //when
    var descriptor = await service.writeDescriptor(
        "123", "456", Uint8List.fromList([1, 2, 3, 4]),
        transactionId: "a789");

    //then
    expect(descriptor, equals(createDescriptor(0)));
  });

  test("writeDescriptor writes descriptor using manager", () {
    //when
    service.writeDescriptor("123", "456", Uint8List.fromList([1, 2, 3, 4]),
        transactionId: "a789");

    //then
    verify(
      managerForService.writeDescriptorForService(
          service, "123", "456", Uint8List.fromList([1, 2, 3, 4]), "a789"),
    );
  });

  test(
      "writeDescriptor writes descriptor with generated transactionId using manager",
      () {
    //when
    service.writeDescriptor("123", "456", Uint8List.fromList([1, 2, 3, 4]),
        transactionId: null);

    //then
    verify(
      managerForService.writeDescriptorForService(service, "123", "456",
          Uint8List.fromList([1, 2, 3, 4]), argThat(isNotNull)),
    );
  });

  test("monitorCharacteristic streams expected characteristic", () {
    //given
    var streamController = StreamController<CharacteristicWithValue>();
    when(managerForService.monitorCharacteristicForService(
            peripheral, service, "123", "a456"))
        .thenAnswer((_) => streamController.stream);

    //when
    var characteristicNotifications =
        service.monitorCharacteristic("123", transactionId: "a456");
    streamController.sink.add(createCharacteristic(0));
    streamController.sink.add(createCharacteristic(1));
    streamController.sink.add(createCharacteristic(2));
    streamController.close();

    //then
    expect(
        characteristicNotifications,
        emitsInOrder([
          emits(equals(createCharacteristic(0))),
          emits(equals(createCharacteristic(1))),
          emits(equals(createCharacteristic(2))),
          emitsDone
        ]));
  });

  test("monitorCharacteristic monitors characteristic using manager", () {
    //when
    service.monitorCharacteristic("123", transactionId: "a456");

    //then
    verify(
      managerForService.monitorCharacteristicForService(
          peripheral, service, "123", "a456"),
    );
  });

  test(
      "monitorCharacteristic monitors characteristic with generated transactionId using manager",
      () {
    //when
    service.monitorCharacteristic("123", transactionId: null);

    //then
    verify(
      managerForService.monitorCharacteristicForService(
          peripheral, service, "123", argThat(isNotNull)),
    );
  });
}
