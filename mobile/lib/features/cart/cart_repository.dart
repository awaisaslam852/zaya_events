import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_client.dart';

class CartRepository {
  CartRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> list() {
    return _client.get('/cart', parse: (data) => Map<String, dynamic>.from(data as Map));
  }

  Future<Either<Failure, Map<String, dynamic>>> add(Map<String, dynamic> body) {
    return _client.post('/cart', data: body, parse: (data) => Map<String, dynamic>.from(data as Map));
  }

  Future<Either<Failure, Unit>> remove(String id) {
    return _client.delete('/cart/$id', parse: (_) => unit);
  }

  Future<Either<Failure, Unit>> clear() {
    return _client.delete('/cart', parse: (_) => unit);
  }

  Future<Either<Failure, Map<String, dynamic>>> checkout({String? eventId}) {
    return _client.post(
      '/cart/checkout',
      data: {if (eventId != null) 'eventId': eventId},
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }
}
