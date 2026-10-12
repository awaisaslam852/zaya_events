import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/accommodations_item.dart';

abstract class AccommodationsRepository {
  Future<Either<Failure, Paginated<AccommodationsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, AccommodationsItem>> getById(String id);

  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);

}
