import 'package:nanoid/nanoid.dart';

class Generate {
  static String generatePocketBaseId() {
    return customAlphabet('0123456789abcdefghijklmnopqrstuvwxyz', 15);
  }

  static String generateUsername(String userId) {
    return 'Ẩn danh $userId';
  }
}
