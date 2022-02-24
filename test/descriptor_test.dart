import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_managers_for_classes.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_util/descriptor_generator.dart';

import './descriptor_test.mocks.dart';

@GenerateMocks([ManagerForDescriptor, Characteristic])
void main() {
  final managerForDescriptor = MockManagerForDescriptor();
  when(
    managerForDescriptor.readDescriptorForIdentifier(any, any)
  ).thenAnswer(
    (_) async => Uint8List.fromList([])
  );
  DescriptorGenerator descriptorGenerator =
      DescriptorGenerator(managerForDescriptor);

  DescriptorWithValue createDescriptor(int seed) =>
      descriptorGenerator.create(seed, MockCharacteristic());

  Descriptor descriptor = createDescriptor(123);

  tearDown(() {
    clearInteractions(managerForDescriptor);
  });

  test("read returns expected value", () async {
    //given
    when(managerForDescriptor.readDescriptorForIdentifier(descriptor, "456"))
        .thenAnswer((_) => Future.value(Uint8List.fromList([1, 2, 3, 4])));

    //when
    var value = await descriptor.read(transactionId: "456");

    //then
    expect(value, equals(Uint8List.fromList([1, 2, 3, 4])));
  });

  test(
      "read invokes manager with expected params when transactionId is specified",
      () {
    //when
    descriptor.read(transactionId: "456");

    //then
    verify(
      managerForDescriptor.readDescriptorForIdentifier(descriptor, "456"),
    );
  });

  test(
      "read invokes manager with expected params when transactionId is not specified",
      () {
    //when
    descriptor.read();

    //then
    verify(
      managerForDescriptor.readDescriptorForIdentifier(
          descriptor, argThat(isNotNull)),
    );
  });

  test(
      "read invokes manager with unique transactionId when transactionId is not specified",
      () {
    //when
    descriptor.read();
    descriptor.read();

    //then
    var transactionIds = verify(
      managerForDescriptor.readDescriptorForIdentifier(
          descriptor, captureThat(isNotNull)),
    ).captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });

  test(
      "write invokes manager with expected params when transactionId is specified",
      () {
    //when
    descriptor.write(Uint8List.fromList([1, 2, 3, 4]), transactionId: "456");

    //then
    verify(
      managerForDescriptor.writeDescriptorForIdentifier(
          descriptor, Uint8List.fromList([1, 2, 3, 4]), "456"),
    );
  });

  test(
      "write invokes manager with expected params when transactionId is not specified",
      () {
    //when
    descriptor.write(Uint8List.fromList([1, 2, 3, 4]));

    //then
    verify(
      managerForDescriptor.writeDescriptorForIdentifier(
          descriptor, Uint8List.fromList([1, 2, 3, 4]), argThat(isNotNull)),
    );
  });

  test(
      "write invokes manager with unique transactionId when transactionId is not specified",
      () {
    //when
    descriptor.write(Uint8List.fromList([1, 2, 3, 4]));
    descriptor.write(Uint8List.fromList([1, 2, 3, 4]));

    //then
    var transactionIds = verify(
            managerForDescriptor.writeDescriptorForIdentifier(descriptor,
                Uint8List.fromList([1, 2, 3, 4]), captureThat(isNotNull)))
        .captured;
    expect(transactionIds[0], isNot(equals(transactionIds[1])));
  });
}
