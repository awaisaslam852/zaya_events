import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/favorites_item.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, Paginated<FavoritesItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, FavoritesItem>> getById(String id);

}
