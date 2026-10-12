import 'user_entity.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserEntity user;
  final String accessToken;
  final String refreshToken;
}

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.country,
    this.phone,
    this.locale = 'en',
    this.businessNameEn,
    this.businessNameAr,
    this.city,
    this.legalName,
    this.taxId,
    this.website,
    this.avatarPath,
    this.avatarName,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String country;
  final String? phone;
  final String locale;
  final String? businessNameEn;
  final String? businessNameAr;
  final String? city;
  final String? legalName;
  final String? taxId;
  final String? website;
  final String? avatarPath;
  final String? avatarName;
}
