import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/flights_item.dart';
import '../repositories/flights_repository.dart';

class ListFlights {
  ListFlights(this._repository);
  final FlightsRepository _repository;
  Future<Either<Failure, Paginated<FlightsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetFlights {
  GetFlights(this._repository);
  final FlightsRepository _repository;
  Future<Either<Failure, FlightsItem>> call(String id) => _repository.getById(id);
}

class InquireFlights {
  InquireFlights(this._repository);
  final FlightsRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}

