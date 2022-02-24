part of test_scenarios;

typedef Logger = Function(String);

abstract class TestScenario {
  Future<void> runTestScenario(Logger log, Logger errorLogger);
}
