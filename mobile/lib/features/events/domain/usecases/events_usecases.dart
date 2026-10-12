import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/events_item.dart';
import '../repositories/events_repository.dart';

class ListEvents {
  ListEvents(this._repository);
  final EventsRepository _repository;
  Future<Either<Failure, Paginated<EventsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetEvents {
  GetEvents(this._repository);
  final EventsRepository _repository;
  Future<Either<Failure, EventsItem>> call(String id) => _repository.getById(id);
}

class CreateEvent {
  CreateEvent(this._repository);
  final EventsRepository _repository;
  Future<Either<Failure, EventsItem>> call(Map<String, dynamic> body) => _repository.create(body);
}

class UpdateEvent {
  UpdateEvent(this._repository);
  final EventsRepository _repository;
  Future<Either<Failure, EventsItem>> call(String id, Map<String, dynamic> body) => _repository.update(id, body);
}

