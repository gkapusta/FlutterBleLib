import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ble manager must be singleton', () {
    //given
    final firstInstanceOfBlemanager = BleManager();

    //when
    final secondInstanceOfBleManager = BleManager();

    //then
    expect(secondInstanceOfBleManager, same(firstInstanceOfBlemanager));
  });
}
