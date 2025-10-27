import 'package:ct312h_project/models/user.dart';
import 'package:ct312h_project/services/pocketbase_client.dart';
import 'package:http/http.dart';

class AuthService {
  void Function(User? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(
            event.record == null ? null : User.fromMap(event.record!.toJson()),
          );
        });
      });
    }
  }

  Future<User> signup(String email, String username, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final record = await pb
          .collection('users')
          .create(
            body: {
              'email': email,
              'username': username,
              'password': password,
              'passwordConfirm': password,
            },
          );
      final data = record.toJson();

      data['email'] = email;
      return User.fromMap(data);
    } catch (e) {
      if (e is ClientException) {
        throw Exception(e.message);
      }
      throw Exception('An error occured');
    }
  }

  Future<User> login(String email, String password) async {
    final pb = await getPocketbaseInstance();

    try {
      final record = await pb
          .collection('users')
          .authWithPassword(email, password);

      final data = record.toJson();

      data['email'] = email;

      return User.fromMap(data);
    } catch (e) {
      if (e is ClientException) {
        throw Exception(e.message);
      }
      throw Exception('An error occured');
    }
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  Future<User?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();

    final model = pb.authStore.record;

    if (model == null) return null;

    return User.fromMap(model.toJson());
  }
}
