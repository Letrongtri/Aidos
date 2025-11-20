import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

PocketBase? _pocketBase;

Future<PocketBase> getPocketbaseInstance() async {
  if (_pocketBase != null) return _pocketBase!;

  final prefs = await SharedPreferences.getInstance();

  final store = AsyncAuthStore(
    save: (String data) async => prefs.setString('pb_auth', data),
    initial: prefs.getString('pb_auth'),
  );

  final baseUrl = dotenv.env['POCKETBASE_URL'] ?? 'http://10.0.2.2:8090';
  _pocketBase = PocketBase(baseUrl, authStore: store);
  return _pocketBase!;
}

Future<String?> getCurrentUserId() async {
  final pb = await getPocketbaseInstance();
  return pb.authStore.record?.id;
}
