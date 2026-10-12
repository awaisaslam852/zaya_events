import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/accommodations_item.dart';
import '../repositories/accommodations_repository.dart';

class ListAccommodations {
  ListAccommodations(this._repository);
  final AccommodationsRepository _repository;
  Future<Either<Failure, Paginated<AccommodationsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetAccommodations {
  GetAccommodations(this._repository);
  final AccommodationsRepository _repository;
  Future<Either<Failure, AccommodationsItem>> call(String id) => _repository.getById(id);
}

class InquireAccommodations {
  InquireAccommodations(this._repository);
  final AccommodationsRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}

