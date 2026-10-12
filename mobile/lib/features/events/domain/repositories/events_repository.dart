import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/events_item.dart';

abstract class EventsRepository {
  Future<Either<Failure, Paginated<EventsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, EventsItem>> getById(String id);
  Future<Either<Failure, EventsItem>> create(Map<String, dynamic> body);
  Future<Either<Failure, EventsItem>> update(String id, Map<String, dynamic> body);
}
