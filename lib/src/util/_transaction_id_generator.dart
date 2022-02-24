import 'package:meta/meta.dart';

abstract class TransactionIdGenerator {
  static int _id = 0;

  @visibleForTesting
  static int get id => _id;

  static String getNextId() {
    _id++;
    return _id.toString();
  }
}
