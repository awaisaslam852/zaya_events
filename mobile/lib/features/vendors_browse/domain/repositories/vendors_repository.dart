import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/vendors_item.dart';

abstract class VendorsRepository {
  Future<Either<Failure, Paginated<VendorsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, VendorsItem>> getById(String id);

}
