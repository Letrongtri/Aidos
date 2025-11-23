import 'package:flutter_dotenv/flutter_dotenv.dart';

class Url {
  static String getPostImageUrl(String postId, String imageName) {
    String url = dotenv.env['POCKETBASE_URL'] ?? 'http://127.0.0.1:8090';
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return '$url/api/files/posts/$postId/$imageName';
  }
}
