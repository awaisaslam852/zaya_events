import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/flights_item.dart';

abstract class FlightsRepository {
  Future<Either<Failure, Paginated<FlightsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, FlightsItem>> getById(String id);

  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);

}
