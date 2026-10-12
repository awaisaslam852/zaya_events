import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/cars_item.dart';
import '../repositories/cars_repository.dart';

class ListCars {
  ListCars(this._repository);
  final CarsRepository _repository;
  Future<Either<Failure, Paginated<CarsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetCars {
  GetCars(this._repository);
  final CarsRepository _repository;
  Future<Either<Failure, CarsItem>> call(String id) => _repository.getById(id);
}

class InquireCars {
  InquireCars(this._repository);
  final CarsRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}

