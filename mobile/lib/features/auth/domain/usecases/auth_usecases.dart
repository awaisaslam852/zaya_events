import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase extends UseCase<AuthSession, LoginParams> {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSession>> call(LoginParams params) => _repository.login(params);
}

class RegisterUseCase extends UseCase<AuthSession, RegisterParams> {
  RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSession>> call(RegisterParams params) => _repository.register(params);
}

class RestoreSessionUseCase extends UseCase<AuthSession?, NoParams> {
  RestoreSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, AuthSession?>> call(NoParams params) => _repository.restore();
}

class LogoutUseCase extends UseCase<Unit, NoParams> {
  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(NoParams params) => _repository.logout();
}

class GetMeUseCase extends UseCase<dynamic, NoParams> {
  GetMeUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, dynamic>> call(NoParams params) => _repository.me();
}

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(String email) => _repository.forgotPassword(email);
}

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({required String token, required String password}) {
    return _repository.resetPassword(token: token, password: password);
  }
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, dynamic>> call(Map<String, dynamic> body) => _repository.updateProfile(body);
}
