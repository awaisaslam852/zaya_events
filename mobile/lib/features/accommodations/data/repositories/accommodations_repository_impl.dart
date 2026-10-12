import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/accommodations_item.dart';
import '../../domain/repositories/accommodations_repository.dart';

class AccommodationsRepositoryImpl implements AccommodationsRepository {
  AccommodationsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<AccommodationsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => AccommodationsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<AccommodationsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/accommodations', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, AccommodationsItem>> getById(String id) {
    return _client.get('/accommodations/$id', parse: (data) => AccommodationsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body) {
    return _client.post('/accommodations/{id}/book'.replaceAll('{id}', id), data: body, parse: (data) => Map<String, dynamic>.from(data as Map));
  }

}
