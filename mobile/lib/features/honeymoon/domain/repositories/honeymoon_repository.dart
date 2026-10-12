import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/honeymoon_item.dart';

abstract class HoneymoonRepository {
  Future<Either<Failure, Paginated<HoneymoonItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, HoneymoonItem>> getById(String id);

  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);

}
