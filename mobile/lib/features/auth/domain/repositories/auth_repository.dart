import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_session.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login(LoginParams params);
  Future<Either<Failure, AuthSession>> register(RegisterParams params);
  Future<Either<Failure, UserEntity>> me();
  Future<Either<Failure, UserEntity>> updateProfile(Map<String, dynamic> body);
  Future<Either<Failure, Unit>> forgotPassword(String email);
  Future<Either<Failure, Unit>> resetPassword({required String token, required String password});
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, AuthSession?>> restore();
}
