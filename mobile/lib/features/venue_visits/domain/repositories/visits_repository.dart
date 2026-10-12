import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/visits_item.dart';

abstract class VisitsRepository {
  Future<Either<Failure, Paginated<VisitsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, VisitsItem>> getById(String id);
  Future<Either<Failure, VisitsItem>> cancel(String id);
  Future<Either<Failure, VisitsItem>> decide(String id, {required bool accepted});
}
