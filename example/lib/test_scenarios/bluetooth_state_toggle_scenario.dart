part of test_scenarios;

class BluetoothStateTestScenario implements TestScenario {
  StreamSubscription<BluetoothState>? _radioStateSubscription;

  @override
  Future<void> runTestScenario(Logger log, Logger errorLogger) async {
    BleManager bleManager = BleManager();

    log("SCENARIO WON'T WORK IF BLUETOOTH IS ENABLED");
    log("Waiting 10 seconds for user to turn BT off");
    await Future.delayed(Duration(seconds: 10));

    log("Creating client...");
    await bleManager.createClient();
    log("Created client");

    log("Subscribe for radio state changes");
    _observeRadioState(bleManager, log);

    log("Get radio state: ${await bleManager.bluetoothState()}");

    log("Enabling radio...");
    try {
      await bleManager.enableRadio();
    } catch (e) {
      errorLogger(e.toString());
    }

    log("Enabled radio!");

    log("Get radio state: ${await bleManager.bluetoothState()}");

    log("Waiting 10 seconds before disabling radio...");
    await Future.delayed(Duration(seconds: 10));

    log("Disabling radio...");
    await bleManager.disableRadio().catchError((error) => errorLogger(error));
    log("Disabled radio!");

    log("Destroying client");
    await _radioStateSubscription?.cancel();
    await bleManager.destroyClient();
    log("Destroyed client!");
  }

  void _observeRadioState(BleManager bleManager, Logger log) async {
    await _radioStateSubscription?.cancel();
    _radioStateSubscription =
        bleManager.observeBluetoothState().listen((newState) {
      log("New radio state: $newState");
    }, onError: (error) {
      log("Error while observing radio state. Error: $error");
    });
  }
}
