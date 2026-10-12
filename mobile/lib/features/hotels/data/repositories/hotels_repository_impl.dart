import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/hotels_item.dart';
import '../../domain/repositories/hotels_repository.dart';

class HotelsRepositoryImpl implements HotelsRepository {
  HotelsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<HotelsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => HotelsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<HotelsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/hotels', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, HotelsItem>> getById(String id) {
    return _client.get('/hotels/$id', parse: (data) => HotelsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body) {
    return _client.post('/hotels/{id}/book'.replaceAll('{id}', id), data: body, parse: (data) => Map<String, dynamic>.from(data as Map));
  }

}
