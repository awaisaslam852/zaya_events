import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';

class VendorDashboardRepository {
  VendorDashboardRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> me() =>
      _client.get('/vendors/me', parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Map<String, dynamic>>> earnings() =>
      _client.get('/vendors/me/earnings', parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Map<String, dynamic>>> reviews() =>
      _client.get('/vendors/me/reviews', parse: (d) => Map<String, dynamic>.from(d as Map));

  Future<Either<Failure, Map<String, dynamic>>> updateMe(Map<String, dynamic> body) =>
      _client.patch('/vendors/me', data: body, parse: (d) => Map<String, dynamic>.from(d as Map));
}

class GetVendorMe {
  GetVendorMe(this._repo);
  final VendorDashboardRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call() => _repo.me();
}

class GetVendorEarnings {
  GetVendorEarnings(this._repo);
  final VendorDashboardRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call() => _repo.earnings();
}

class GetVendorReviews {
  GetVendorReviews(this._repo);
  final VendorDashboardRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call() => _repo.reviews();
}

class UpdateVendorProfile {
  UpdateVendorProfile(this._repo);
  final VendorDashboardRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> body) => _repo.updateMe(body);
}
