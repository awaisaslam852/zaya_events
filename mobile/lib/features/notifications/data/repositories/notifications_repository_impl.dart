import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/notifications_item.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<NotificationsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => NotificationsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<NotificationsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/notifications', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, NotificationsItem>> getById(String id) {
    return _client.get('/notifications/$id', parse: (data) => NotificationsItem(Map<String, dynamic>.from(data as Map)));
  }

}
