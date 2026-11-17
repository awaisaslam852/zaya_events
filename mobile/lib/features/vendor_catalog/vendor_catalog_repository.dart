import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/pagination/paginated.dart';
import 'vendor_catalog_kind.dart';

class VendorCatalogRepository {
  VendorCatalogRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Paginated<Map<String, dynamic>>>> list(
    VendorCatalogKind kind, {
    int page = 1,
  }) {
    if (kind == VendorCatalogKind.all) {
      return listAll();
    }
    return _client.get(
      '/${kind.path}',
      query: {'page': page, 'pageSize': 50},
      parse: (data) {
        final pageData = _page(data);
        return Paginated(
          items: pageData.items
              .map((item) => withCatalogKind(item, kind))
              .toList(),
          total: pageData.total,
          page: pageData.page,
          pageSize: pageData.pageSize,
        );
      },
    );
  }

  Future<Either<Failure, Paginated<Map<String, dynamic>>>> listAll() async {
    final kinds = VendorCatalogKind.sellable;
    final results = await Future.wait(kinds.map(list));
    final items = <Map<String, dynamic>>[];
    String? lastError;
    var anyOk = false;
    for (final result in results) {
      result.fold(
        (failure) => lastError = failure.message,
        (page) {
          anyOk = true;
          items.addAll(page.items);
        },
      );
    }
    if (!anyOk) {
      return left(ServerFailure(lastError ?? 'Unable to load catalog'));
    }
    return right(
      Paginated(
        items: items,
        total: items.length,
        page: 1,
        pageSize: items.length,
      ),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> getById(
    VendorCatalogKind kind,
    String id,
  ) {
    return _client.get(
      '/${kind.path}/$id',
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> create(
    VendorCatalogKind kind,
    Map<String, dynamic> body,
  ) {
    return _client.post(
      '/${kind.path}',
      data: body,
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> update(
    VendorCatalogKind kind,
    String id,
    Map<String, dynamic> body,
  ) {
    return _client.patch(
      '/${kind.path}/$id',
      data: body,
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Either<Failure, Unit>> remove(VendorCatalogKind kind, String id) {
    return _client.delete('/${kind.path}/$id', parse: (_) => unit);
  }

  Paginated<Map<String, dynamic>> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }
}
