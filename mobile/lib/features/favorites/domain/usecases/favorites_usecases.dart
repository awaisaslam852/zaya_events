import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/favorites_item.dart';
import '../repositories/favorites_repository.dart';

class ListFavorites {
  ListFavorites(this._repository);
  final FavoritesRepository _repository;
  Future<Either<Failure, Paginated<FavoritesItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetFavorites {
  GetFavorites(this._repository);
  final FavoritesRepository _repository;
  Future<Either<Failure, FavoritesItem>> call(String id) => _repository.getById(id);
}

class RemoveFavorite {
  RemoveFavorite(this._repository);
  final FavoritesRepository _repository;
  Future<Either<Failure, bool>> call({required String resourceType, required String resourceId}) =>
      _repository.remove(resourceType: resourceType, resourceId: resourceId);
}

