import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
abstract class AuthEvent with _$AuthEvent {
  const factory AuthEvent.started() = _Started;
  const factory AuthEvent.login({required String email, required String password}) = _Login;
  const factory AuthEvent.register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    required String country,
    String? phone,
    String? locale,
    String? businessNameEn,
    String? businessNameAr,
    String? city,
    String? legalName,
    String? taxId,
    String? website,
    String? avatarPath,
    String? avatarName,
  }) = _Register;
  const factory AuthEvent.logout() = _Logout;
  const factory AuthEvent.userUpdated() = _UserUpdated;
}
