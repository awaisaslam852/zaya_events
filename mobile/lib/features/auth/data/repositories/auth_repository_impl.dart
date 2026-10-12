import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client, this._storage);

  final ApiClient _client;
  final TokenStorage _storage;

  UserEntity _toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      role: model.role,
      firstName: model.firstName,
      lastName: model.lastName,
      phone: model.phone,
      displayName: model.displayName,
      avatarKey: model.avatarKey,
      locale: model.locale,
      status: model.status,
      vendor: model.vendor,
    );
  }

  UserEntity _userFrom(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final user = Map<String, dynamic>.from(map['user'] as Map? ?? map);
    return _toEntity(UserModel.fromJson(user));
  }

  AuthSession _sessionFrom(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final tokens = Map<String, dynamic>.from(map['tokens'] as Map);
    return AuthSession(
      user: _userFrom(map),
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );
  }

  Future<Either<Failure, AuthSession>> _persist(Either<Failure, AuthSession> result) async {
    return result.fold(left, (session) async {
      await _storage.save(access: session.accessToken, refresh: session.refreshToken);
      return Right(session);
    });
  }

  @override
  Future<Either<Failure, AuthSession>> login(LoginParams params) {
    return _client
        .post(
          '/auth/login',
          data: {'email': params.email, 'password': params.password},
          parse: _sessionFrom,
        )
        .then(_persist);
  }

  @override
  Future<Either<Failure, AuthSession>> register(RegisterParams params) {
    final body = <String, dynamic>{
      'email': params.email,
      'password': params.password,
      'firstName': params.firstName,
      'lastName': params.lastName,
      'role': params.role,
      'locale': params.locale,
      'country': params.country,
      if (params.phone != null && params.phone!.isNotEmpty) 'phone': params.phone,
      if (params.city != null && params.city!.isNotEmpty) 'city': params.city,
      if (params.legalName != null && params.legalName!.isNotEmpty) 'legalName': params.legalName,
      if (params.role == 'vendor')
        'businessName': {'en': params.businessNameEn, 'ar': params.businessNameAr},
    };
    return _client.post('/auth/register', data: body, parse: _sessionFrom).then((result) async {
      final persisted = await _persist(result);
      return persisted.fold(left, (session) async {
        final path = params.avatarPath;
        if (path == null || path.isEmpty) {
          return Right(session);
        }
        final form = FormData.fromMap({
          'folder': 'avatars',
          'file': await MultipartFile.fromFile(path, filename: params.avatarName ?? 'avatar.jpg'),
        });
        final uploaded = await _client.upload(
          '/uploads',
          data: form,
          parse: (data) => Map<String, dynamic>.from(data as Map),
        );
        await uploaded.fold((_) async {}, (file) async {
          final key = file['key']?.toString();
          if (key != null && key.isNotEmpty) {
            await updateProfile({'avatarKey': key});
          }
        });
        final me = await this.me();
        return me.fold(
          (_) => Right(session),
          (user) => Right(AuthSession(user: user, accessToken: session.accessToken, refreshToken: session.refreshToken)),
        );
      });
    });
  }

  @override
  Future<Either<Failure, UserEntity>> me() {
    return _client.get('/auth/me', parse: _userFrom);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> body) {
    return _client.patch('/auth/me', data: body, parse: _userFrom);
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) {
    return _client.post('/auth/forgot-password', data: {'email': email}, parse: (_) => unit);
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String token, required String password}) {
    return _client.post(
      '/auth/reset-password',
      data: {'token': token, 'password': password},
      parse: (_) => unit,
    );
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final refresh = await _storage.readRefresh();
    await _client.post(
      '/auth/logout',
      data: {if (refresh != null) 'refreshToken': refresh},
      parse: (_) => unit,
    );
    await _storage.clear();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, AuthSession?>> restore() async {
    try {
      final access = await _storage.readAccess();
      if (access == null) {
        return const Right(null);
      }
      final meResult = await me();
      return meResult.fold(left, (user) async {
        final refresh = await _storage.readRefresh() ?? '';
        return Right(AuthSession(user: user, accessToken: access, refreshToken: refresh));
      });
    } catch (_) {
      return const Right(null);
    }
  }
}
