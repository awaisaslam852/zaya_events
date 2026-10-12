import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/vendors_item.dart';
import '../../domain/repositories/vendors_repository.dart';

class VendorsRepositoryImpl implements VendorsRepository {
  VendorsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<VendorsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => VendorsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<VendorsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/vendors', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, VendorsItem>> getById(String id) {
    return _client.get('/vendors/$id', parse: (data) => VendorsItem(Map<String, dynamic>.from(data as Map)));
  }

}
