import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/hotels_item.dart';
import '../repositories/hotels_repository.dart';

class ListHotels {
  ListHotels(this._repository);
  final HotelsRepository _repository;
  Future<Either<Failure, Paginated<HotelsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetHotels {
  GetHotels(this._repository);
  final HotelsRepository _repository;
  Future<Either<Failure, HotelsItem>> call(String id) => _repository.getById(id);
}

class InquireHotels {
  InquireHotels(this._repository);
  final HotelsRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}

