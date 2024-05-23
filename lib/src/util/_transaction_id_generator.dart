abstract class TransactionIdGenerator {
  static int _id = 0;

  static String getNextId() {
    _id++;
    return _id.toString();
  }
}
