import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_ble_lib/src/_managers_for_classes.dart';
import 'package:mockito/mockito.dart';


class ManagerForCharacteristicMock extends Mock
    implements ManagerForCharacteristic {}

class ManagerForDescriptorMock extends Mock implements ManagerForDescriptor {}

class ServiceMock extends Mock implements Service {}

class PeripheralMock extends Mock implements Peripheral {}

class CharacteristicMock extends Mock implements Characteristic {}
