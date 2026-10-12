import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/honeymoon_item.dart';
import '../repositories/honeymoon_repository.dart';

class ListHoneymoon {
  ListHoneymoon(this._repository);
  final HoneymoonRepository _repository;
  Future<Either<Failure, Paginated<HoneymoonItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetHoneymoon {
  GetHoneymoon(this._repository);
  final HoneymoonRepository _repository;
  Future<Either<Failure, HoneymoonItem>> call(String id) => _repository.getById(id);
}

class InquireHoneymoon {
  InquireHoneymoon(this._repository);
  final HoneymoonRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, Map<String, dynamic> body) =>
      _repository.inquire(id, body);
}

