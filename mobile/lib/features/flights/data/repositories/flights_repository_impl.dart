import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/flights_item.dart';
import '../../domain/repositories/flights_repository.dart';

class FlightsRepositoryImpl implements FlightsRepository {
  FlightsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<FlightsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => FlightsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<FlightsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/flights', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, FlightsItem>> getById(String id) {
    return _client.get('/flights/$id', parse: (data) => FlightsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body) {
    return _client.post('/flights/{id}/book'.replaceAll('{id}', id), data: body, parse: (data) => Map<String, dynamic>.from(data as Map));
  }

}
