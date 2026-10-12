import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/cars_item.dart';

abstract class CarsRepository {
  Future<Either<Failure, Paginated<CarsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, CarsItem>> getById(String id);

  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);

}
