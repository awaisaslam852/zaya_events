import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/venues_item.dart';

abstract class VenuesRepository {
  Future<Either<Failure, Paginated<VenuesItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, VenuesItem>> getById(String id);

  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);

}
