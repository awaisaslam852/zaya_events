import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/hotels_item.dart';

abstract class HotelsRepository {
  Future<Either<Failure, Paginated<HotelsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, HotelsItem>> getById(String id);

  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body);

}
