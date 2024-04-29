part of '../_internal.dart';

mixin LogLevelMixin on FlutterBLE {
  Future<void> setLogLevel(LogLevel logLevel) async {
    debugPrint("set log level to ${logLevel.name}");
    return await _methodChannel.invokeMethod(
      MethodName.setLogLevel,
      <String, dynamic>{
        ArgumentName.logLevel: logLevel.name,
      },
    ).catchError((errorJson) =>
        Future.error(BleError.fromJson(jsonDecode(errorJson.details))));
  }

  Future<LogLevel> logLevel() async {
    String logLevelName =
        await _methodChannel.invokeMethod(MethodName.logLevel);
    return _logLevelFromString(logLevelName);
  }

  LogLevel _logLevelFromString(String logLevelName) {
    debugPrint("try to get log level from: $logLevelName");
    return LogLevel.values.firstWhere(
        (e) => e.toString() == 'LogLevel.${logLevelName.toLowerCase()}');
  }
}
