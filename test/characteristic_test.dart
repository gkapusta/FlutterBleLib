import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_managers_for_classes.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import './characteristic_test.mocks.dart';

import 'test_util/characteristic_generator.dart';
import 'test_util/descriptor_generator.dart';

@GenerateMocks(
  [Peripheral, ManagerForDescriptor, DescriptorWithValue],
  customMocks: [
    MockSpec<Service>(returnNullOnMissingStub: true),
  ]
)
void main() {
  final peripheral = MockPeripheral();
  when(peripheral.toString()).thenReturn("mocked peripheral toString()");
  final managerForCharacteristic =
      MockManagerForCharacteristic();
  when(
    managerForCharacteristic.readCharacteristicForIdentifier(any, any, any)
  ).thenAnswer(
    (_) async => Uint8List.fromList([])
  );
  when(
    managerForCharacteristic.monitorCharacteristicForIdentifier(any, any, any)
  ).thenAnswer(
    (_) => Stream.value(Uint8List.fromList([]))
  );
  when(
    managerForCharacteristic.readDescriptorForCharacteristic(any, any, any)
  ).thenAnswer(
    (_) async => MockDescriptorWithValue()
  );
  when(
    managerForCharacteristic.writeDescriptorForCharacteristic(any, any, any, any)
  ).thenAnswer(
    (_) async => MockDescriptorWithValue()
  );
  final characteristicGenerator =
      CharacteristicGenerator(managerForCharacteristic);
  final descriptorGenerator =
      DescriptorGenerator(MockManagerForDescriptor());
  final service = MockService();
  when(service.peripheral).thenReturn(peripheral);
  when(service.toString()).thenReturn("mocked service toString()");

  final characteristic =
      characteristicGenerator.create(123, service);

  DescriptorWithValue createDescriptor(int seed) =>
      descriptorGenerator.create(seed, characteristic);

  tearDown(() {
    [
      peripheral,
      managerForCharacteristic,
    ].forEach(clearInteractions);
  });

  test("descriptors returns a list of descriptors provided by manager", () async {
    //given
    when(managerForCharacteristic.descriptorsForCharacteristic(characteristic))
        .thenAnswer((_) => Future.value([
              createDescriptor(0),
              createDescriptor(1),
              createDescriptor(2),
            ]));

    //when
    var descriptors = await characteristic.descriptors();

    //then
    expect(
        descriptors,
        equals([
          createDescriptor(0),
          createDescriptor(1),
          createDescriptor(2),
        ]));
  });

  test("read returns expected value", () async {
    //given
    when(managerForCharacteristic.readCharacteristicForIdentifier(
            any, characteristic, "a123"))
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3, 4])));

    //when
    var value = await characteristic.read(transactionId: "a123");

    //then
    expect(value, equals(Uint8List.fromList([1, 2, 3, 4])));
  });

  test(
      "read invokes manager with expected params when transactionId is specified",
      () {
    //when
    characteristic.read(transactionId: "a123");

    //then
    verify(
      managerForCharacteristic.readCharacteristicForIdentifier(
          any, characteristic, "a123"),
    );
  });

  test(
      "read generates transactionId when it is not specified",
      () {
    //when
    characteristic.read();

    //then
    verify(
      managerForCharacteristic.readCharacteristicForIdentifier(
          any, characteristic, argThat(isNotNull)),
    );
  });

  test(
      "read generates unique transactionId for each operation",
      () {
    //when
    characteristic.read();
    characteristic.read();

    //then
    final transactionIds = verify(
      managerForCharacteristic.readCharacteristicForIdentifier(
          any, characteristic, captureThat(isNotNull)),
    ).captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });

  test(
      "write invokes manager with expected params when transactionId is specified",
      () {
    //when
    characteristic.write(
      Uint8List.fromList([1, 2, 3, 4]),
      false,
      transactionId: "a456",
    );

    //then
    verify(
      managerForCharacteristic.writeCharacteristicForIdentifier(
          any, characteristic, Uint8List.fromList([1, 2, 3, 4]), false, "a456"),
    );
  });

  test(
      "write invokes manager with expected params when transactionId is not specified",
      () {
    //when
    characteristic.write(Uint8List.fromList([1, 2, 3, 4]), false);

    //then
    verify(
      managerForCharacteristic.writeCharacteristicForIdentifier(
          any,
          characteristic,
          Uint8List.fromList([1, 2, 3, 4]),
          false,
          argThat(isNotNull)),
    );
  });

  test(
      "write invokes manager with unique transactionId when transactionId is not specified",
      () {
    //when
    characteristic.write(Uint8List.fromList([1, 2, 3, 4]), false);
    characteristic.write(Uint8List.fromList([1, 2, 3, 4]), false);

    //then
    var transactionIds = verify(
            managerForCharacteristic.writeCharacteristicForIdentifier(
                any,
                characteristic,
                Uint8List.fromList([1, 2, 3, 4]),
                false,
                captureThat(isNotNull)))
        .captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });

  test("monitor emits expected values", () {
    //given
    var streamController = StreamController<Uint8List>();
    when(managerForCharacteristic.monitorCharacteristicForIdentifier(
            any, characteristic, "a123"))
        .thenAnswer((_) => streamController.stream);

    //when
    var valuesNotifications = characteristic.monitor(transactionId: "a123");
    streamController.sink.add(Uint8List.fromList([1, 2, 3]));
    streamController.sink.add(Uint8List.fromList([4, 5, 6]));
    streamController.sink.add(Uint8List.fromList([7, 8, 9]));
    streamController.close();

    //then
    expect(
        valuesNotifications,
        emitsInOrder([
          emits(equals(Uint8List.fromList([1, 2, 3]))),
          emits(equals(Uint8List.fromList([4, 5, 6]))),
          emits(equals(Uint8List.fromList([7, 8, 9]))),
          emitsDone
        ]));
  });

  test(
      "monitor invokes manager with expected params when transactionId is specified",
      () {
    //when
    characteristic.monitor(transactionId: "a123");

    //then
    verify(
      managerForCharacteristic.monitorCharacteristicForIdentifier(
          any, characteristic, "a123"),
    );
  });

  test(
      "monitor invokes manager with expected params when transactionId is not specified",
      () {
    //when
    characteristic.monitor();

    //then
    verify(
      managerForCharacteristic.monitorCharacteristicForIdentifier(
          any, characteristic, argThat(isNotNull)),
    );
  });

  test(
      "monitor invokes manager with unique transactionId when transactionId is not specified",
      () {
    //when
    characteristic.monitor();
    characteristic.monitor();

    //then
    var transactionIds = verify(
            managerForCharacteristic.monitorCharacteristicForIdentifier(
                any, characteristic, captureThat(isNotNull)))
        .captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });

  test("readDescriptor returns expected descriptor", () async {
    //given
    when(managerForCharacteristic.readDescriptorForCharacteristic(
            characteristic, "123", "a456"))
        .thenAnswer((_) => Future.value(createDescriptor(0)));

    //when
    var descriptor =
        await characteristic.readDescriptor("123", transactionId: "a456");

    //then
    expect(descriptor, equals(createDescriptor(0)));
  });

  test(
      "readDescriptor invokes manager with expected params when transactionId is specified",
      () {
    //when
    characteristic.readDescriptor("123", transactionId: "a456");

    //then
    verify(
      managerForCharacteristic.readDescriptorForCharacteristic(
          characteristic, "123", "a456"),
    );
  });

  test(
      "readDescriptor invokes manager with expected params when transactionId is not specified",
      () {
    //when
    characteristic.readDescriptor("123", transactionId: "a456");

    //then
    verify(
      managerForCharacteristic.readDescriptorForCharacteristic(
          characteristic, "123", argThat(isNotNull)),
    );
  });

  test(
      "readDescriptor invokes manager with unique transactionId when transactionId is not specified",
      () {
    //when
    characteristic.readDescriptor("123");
    characteristic.readDescriptor("123");

    //then
    var transactionIds = verify(
      managerForCharacteristic.readDescriptorForCharacteristic(
          characteristic, "123", captureThat(isNotNull)),
    ).captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });

  test("writeDescriptor returns expected descriptor", () async {
    //given
    when(managerForCharacteristic.writeDescriptorForCharacteristic(
            characteristic, "123", Uint8List.fromList([1, 2, 3, 4]), "a456"))
        .thenAnswer((_) => Future.value(createDescriptor(0)));

    //when
    var descriptor = await characteristic.writeDescriptor(
      "123",
      Uint8List.fromList([1, 2, 3, 4]),
      transactionId: "a456",
    );

    //then
    expect(descriptor, equals(createDescriptor(0)));
  });

  test(
      "writeDescriptor invokes manager with expected params when transactionId is specified",
      () {
    //when
    characteristic.writeDescriptor(
      "123",
      Uint8List.fromList([1, 2, 3, 4]),
      transactionId: "a456",
    );

    //then
    verify(
      managerForCharacteristic.writeDescriptorForCharacteristic(
          characteristic, "123", Uint8List.fromList([1, 2, 3, 4]), "a456"),
    );
  });

  test(
      "writeDescriptor invokes manager with expected params when transactionId is not specified",
      () {
    //when
    characteristic.writeDescriptor("123", Uint8List.fromList([1, 2, 3, 4]));
    //then
    verify(
      managerForCharacteristic.writeDescriptorForCharacteristic(
        characteristic,
        "123",
        Uint8List.fromList([1, 2, 3, 4]),
        argThat(isNotNull),
      ),
    );
  });

  test(
      "writeDescriptor invokes manager with unique transactionId when transactionId is not specified",
      () {
    //when
    characteristic.writeDescriptor("123", Uint8List.fromList([1, 2, 3, 4]));
    characteristic.writeDescriptor("123", Uint8List.fromList([1, 2, 3, 4]));

    //then
    var transactionIds = verify(
      managerForCharacteristic.writeDescriptorForCharacteristic(
          characteristic,
          "123",
          Uint8List.fromList([1, 2, 3, 4]),
          captureThat(isNotNull)),
    ).captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });
}
