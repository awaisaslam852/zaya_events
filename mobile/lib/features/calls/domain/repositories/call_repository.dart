import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/call_entity.dart';

abstract class CallRepository {
  Future<Either<Failure, CallEntity>> initiate({required String calleeId, String? bookingId});
  Future<Either<Failure, CallEntity>> accept(String id);
  Future<Either<Failure, CallEntity>> reject(String id);
  Future<Either<Failure, CallEntity>> end(String id);
  Future<Either<Failure, CallToken>> token(String id);
  Future<Either<Failure, Paginated<CallEntity>>> history({int page = 1});
}
