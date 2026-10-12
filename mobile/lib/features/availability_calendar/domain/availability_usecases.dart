import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/pagination/paginated.dart';

class AvailabilityRepository {
  AvailabilityRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Paginated<Map<String, dynamic>>>> list({int page = 1}) {
    return _client.get('/availability', query: {'page': page}, parse: (data) {
      final map = Map<String, dynamic>.from(data as Map);
      final items = (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      return Paginated(
        items: items,
        total: (map['total'] as num?)?.toInt() ?? items.length,
        page: (map['page'] as num?)?.toInt() ?? 1,
        pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
      );
    });
  }

  Future<Either<Failure, Map<String, dynamic>>> upsert(Map<String, dynamic> body) =>
      _client.post('/availability', data: body, parse: (d) => Map<String, dynamic>.from(d as Map));
}

class ListAvailability {
  ListAvailability(this._repo);
  final AvailabilityRepository _repo;
  Future<Either<Failure, Paginated<Map<String, dynamic>>>> call() => _repo.list();
}

class UpsertAvailability {
  UpsertAvailability(this._repo);
  final AvailabilityRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> body) => _repo.upsert(body);
}
