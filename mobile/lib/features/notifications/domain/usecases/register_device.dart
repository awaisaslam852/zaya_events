import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';

class RegisterDevice {
  RegisterDevice(this._client);
  final ApiClient _client;

  Future<Either<Failure, Unit>> call(String token) {
    return _client.post(
      '/notifications/devices',
      data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
      parse: (_) => unit,
    );
  }
}
