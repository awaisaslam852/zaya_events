import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/pagination/paginated.dart';

class ListingsRepository {
  ListingsRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Paginated<Map<String, dynamic>>>> list({int page = 1}) {
    return _client.get('/listings', query: {'page': page}, parse: _page);
  }

  Future<Either<Failure, Map<String, dynamic>>> getById(String id) =>
      _client.get('/listings/$id', parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Map<String, dynamic>>> create(Map<String, dynamic> body) =>
      _client.post('/listings', data: body, parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Map<String, dynamic>>> update(String id, Map<String, dynamic> body) =>
      _client.patch('/listings/$id', data: body, parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Unit>> remove(String id) =>
      _client.delete('/listings/$id', parse: (_) => unit);

  Future<Either<Failure, Map<String, dynamic>>> addPackage(String id, Map<String, dynamic> body) =>
      _client.post('/listings/$id/packages', data: body, parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Map<String, dynamic>>> updatePackage(
    String id,
    String packageId,
    Map<String, dynamic> body,
  ) =>
      _client.patch('/listings/$id/packages/$packageId', data: body, parse: (d) => Map<String, dynamic>.from(d as Map));

  Paginated<Map<String, dynamic>> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }
}

class ListVendorListings {
  ListVendorListings(this._repo);
  final ListingsRepository _repo;
  Future<Either<Failure, Paginated<Map<String, dynamic>>>> call() => _repo.list();
}

class CreateListing {
  CreateListing(this._repo);
  final ListingsRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> body) => _repo.create(body);
}

class UpdateListing {
  UpdateListing(this._repo);
  final ListingsRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) => _repo.update(id, body);
}

class GetListing {
  GetListing(this._repo);
  final ListingsRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(String id) => _repo.getById(id);
}

class DeleteListing {
  DeleteListing(this._repo);
  final ListingsRepository _repo;
  Future<Either<Failure, Unit>> call(String id) => _repo.remove(id);
}

class AddListingPackage {
  AddListingPackage(this._repo);
  final ListingsRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repo.addPackage(id, body);
}
