import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/call_entity.dart';
import '../../domain/repositories/call_repository.dart';

class CallRepositoryImpl implements CallRepository {
  CallRepositoryImpl(this._client);
  final ApiClient _client;

  CallEntity _one(dynamic data) => CallEntity.fromJson(Map<String, dynamic>.from(data as Map));

  @override
  Future<Either<Failure, CallEntity>> initiate({required String calleeId, String? bookingId}) {
    return _client.post(
      '/calls/initiate',
      data: {'calleeId': calleeId, if (bookingId != null) 'bookingId': bookingId},
      parse: _one,
    );
  }

  @override
  Future<Either<Failure, CallEntity>> accept(String id) =>
      _client.post('/calls/$id/accept', parse: _one);

  @override
  Future<Either<Failure, CallEntity>> reject(String id) =>
      _client.post('/calls/$id/reject', parse: _one);

  @override
  Future<Either<Failure, CallEntity>> end(String id) => _client.post('/calls/$id/end', parse: _one);

  @override
  Future<Either<Failure, CallToken>> token(String id) {
    return _client.get('/calls/$id/token', parse: (data) => CallToken.fromJson(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, Paginated<CallEntity>>> history({int page = 1}) {
    return _client.get(
      '/calls/history',
      query: {'page': page},
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final items = (map['items'] as List? ?? [])
            .map((e) => CallEntity.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return Paginated(
          items: items,
          total: (map['total'] as num?)?.toInt() ?? items.length,
          page: (map['page'] as num?)?.toInt() ?? 1,
          pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
        );
      },
    );
  }
}
