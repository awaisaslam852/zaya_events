import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/visits_item.dart';
import '../../domain/repositories/visits_repository.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  VisitsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<VisitsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => VisitsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<VisitsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/venue-visits', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, VisitsItem>> getById(String id) {
    return _client.get('/venue-visits/$id', parse: (data) => VisitsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, VisitsItem>> cancel(String id) {
    return _client.post('/venue-visits/$id/cancel', data: {}, parse: (data) => VisitsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, VisitsItem>> decide(String id, {required bool accepted}) {
    return _client.post(
      '/venue-visits/$id/decide',
      data: {'accepted': accepted},
      parse: (data) => VisitsItem(Map<String, dynamic>.from(data as Map)),
    );
  }
}
