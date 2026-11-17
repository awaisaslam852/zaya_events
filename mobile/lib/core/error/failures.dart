sealed class Failure {
  const Failure(this.message, {this.code, this.fieldErrors});
  final String message;
  final String? code;
  final Map<String, String>? fieldErrors;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.fieldErrors});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'offline']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.fieldErrors});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
