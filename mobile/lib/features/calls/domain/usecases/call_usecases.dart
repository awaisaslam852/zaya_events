import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/call_entity.dart';
import '../repositories/call_repository.dart';

class InitiateCall {
  InitiateCall(this._repo);
  final CallRepository _repo;
  Future<Either<Failure, CallEntity>> call({required String calleeId, String? bookingId}) =>
      _repo.initiate(calleeId: calleeId, bookingId: bookingId);
}

class AcceptCall {
  AcceptCall(this._repo);
  final CallRepository _repo;
  Future<Either<Failure, CallEntity>> call(String id) => _repo.accept(id);
}

class RejectCall {
  RejectCall(this._repo);
  final CallRepository _repo;
  Future<Either<Failure, CallEntity>> call(String id) => _repo.reject(id);
}

class EndCall {
  EndCall(this._repo);
  final CallRepository _repo;
  Future<Either<Failure, CallEntity>> call(String id) => _repo.end(id);
}

class GetCallToken {
  GetCallToken(this._repo);
  final CallRepository _repo;
  Future<Either<Failure, CallToken>> call(String id) => _repo.token(id);
}

class ListCallHistory {
  ListCallHistory(this._repo);
  final CallRepository _repo;
  Future<Either<Failure, Paginated<CallEntity>>> call({int page = 1}) => _repo.history(page: page);
}
