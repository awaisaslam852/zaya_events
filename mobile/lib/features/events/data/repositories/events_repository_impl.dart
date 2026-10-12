import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/events_item.dart';
import '../../domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<EventsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => EventsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<EventsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/events', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, EventsItem>> getById(String id) {
    return _client.get('/events/$id', parse: (data) => EventsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, EventsItem>> create(Map<String, dynamic> body) {
    return _client.post('/events', data: body, parse: (data) => EventsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, EventsItem>> update(String id, Map<String, dynamic> body) {
    return _client.patch('/events/$id', data: body, parse: (data) => EventsItem(Map<String, dynamic>.from(data as Map)));
  }
}
