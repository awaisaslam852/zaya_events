import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/venues_item.dart';
import '../repositories/venues_repository.dart';

class ListVenues {
  ListVenues(this._repository);
  final VenuesRepository _repository;
  Future<Either<Failure, Paginated<VenuesItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetVenues {
  GetVenues(this._repository);
  final VenuesRepository _repository;
  Future<Either<Failure, VenuesItem>> call(String id) => _repository.getById(id);
}

class InquireVenues {
  InquireVenues(this._repository);
  final VenuesRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}

