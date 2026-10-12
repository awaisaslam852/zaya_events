import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> login(Map<String, dynamic> body) {
    return _client
        .post('/auth/login', data: body, parse: (data) => Map<String, dynamic>.from(data as Map))
        .then((either) => either.fold((l) => throw Exception(l.message), (r) => r));
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) {
    return _client
        .post('/auth/register', data: body, parse: (data) => Map<String, dynamic>.from(data as Map))
        .then((either) => either.fold((l) => throw Exception(l.message), (r) => r));
  }

  Future<UserModel> me() {
    return _client
        .get('/auth/me', parse: (data) {
          final map = Map<String, dynamic>.from(data as Map);
          return UserModel.fromJson(Map<String, dynamic>.from(map['user'] as Map? ?? map));
        })
        .then((either) => either.fold((l) => throw Exception(l.message), (r) => r));
  }

  Future<UserModel> updateMe(Map<String, dynamic> body) {
    return _client
        .patch('/auth/me', data: body, parse: (data) {
          final map = Map<String, dynamic>.from(data as Map);
          return UserModel.fromJson(Map<String, dynamic>.from(map['user'] as Map? ?? map));
        })
        .then((either) => either.fold((l) => throw Exception(l.message), (r) => r));
  }

  Future<void> logout(Map<String, dynamic> body) {
    return _client
        .post('/auth/logout', data: body, parse: (_) => null)
        .then((either) => either.fold((l) => throw Exception(l.message), (_) {}));
  }

  Future<void> forgot(String email) {
    return _client
        .post('/auth/forgot-password', data: {'email': email}, parse: (_) => null)
        .then((either) => either.fold((l) => throw Exception(l.message), (_) {}));
  }

  Future<void> reset({required String token, required String password}) {
    return _client
        .post('/auth/reset-password', data: {'token': token, 'password': password}, parse: (_) => null)
        .then((either) => either.fold((l) => throw Exception(l.message), (_) {}));
  }
}
