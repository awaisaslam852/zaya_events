import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/vendors_item.dart';
import '../repositories/vendors_repository.dart';

class ListVendors {
  ListVendors(this._repository);
  final VendorsRepository _repository;
  Future<Either<Failure, Paginated<VendorsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetVendors {
  GetVendors(this._repository);
  final VendorsRepository _repository;
  Future<Either<Failure, VendorsItem>> call(String id) => _repository.getById(id);
}

