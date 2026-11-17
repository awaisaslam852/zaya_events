import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/core/network/auth_interceptor.dart';
import 'package:zaya_events/core/storage/token_storage.dart';

void main() {
  test('token storage keeps the latest tokens in memory', () async {
    final storage = TokenStorage.memory();
    await storage.save(access: 'access-1', refresh: 'refresh-1');
    expect(await storage.readAccess(), 'access-1');
    expect(await storage.readRefresh(), 'refresh-1');
    await storage.clear();
    expect(await storage.readAccess(), isNull);
  });

  test('401 without a bearer token does not refresh or log the user out', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/notifications'),
      response: Response(requestOptions: RequestOptions(path: '/notifications'), statusCode: 401),
    );
    expect(shouldAttemptSessionRefresh(err), isFalse);
  });

  test('401 with a bearer token on an authenticated API does refresh', () {
    final err = DioException(
      requestOptions: RequestOptions(
        path: '/notifications',
        headers: {'Authorization': 'Bearer abc'},
      ),
      response: Response(requestOptions: RequestOptions(path: '/notifications'), statusCode: 401),
    );
    expect(shouldAttemptSessionRefresh(err), isTrue);
  });

  test('login and public settings 401s do not refresh the session', () {
    final login = DioException(
      requestOptions: RequestOptions(path: '/auth/login', headers: {'Authorization': 'Bearer abc'}),
      response: Response(requestOptions: RequestOptions(path: '/auth/login'), statusCode: 401),
    );
    final settings = DioException(
      requestOptions: RequestOptions(path: '/settings/public', headers: {'Authorization': 'Bearer abc'}),
      response: Response(requestOptions: RequestOptions(path: '/settings/public'), statusCode: 401),
    );
    expect(shouldAttemptSessionRefresh(login), isFalse);
    expect(shouldAttemptSessionRefresh(settings), isFalse);
  });
}
