import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/visits_item.dart';
import '../repositories/visits_repository.dart';

class ListVisits {
  ListVisits(this._repository);
  final VisitsRepository _repository;
  Future<Either<Failure, Paginated<VisitsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetVisits {
  GetVisits(this._repository);
  final VisitsRepository _repository;
  Future<Either<Failure, VisitsItem>> call(String id) => _repository.getById(id);
}

class CancelVisit {
  CancelVisit(this._repository);
  final VisitsRepository _repository;
  Future<Either<Failure, VisitsItem>> call(String id) => _repository.cancel(id);
}

class DecideVisit {
  DecideVisit(this._repository);
  final VisitsRepository _repository;
  Future<Either<Failure, VisitsItem>> call(String id, {required bool accepted}) =>
      _repository.decide(id, accepted: accepted);
}
