class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.displayName,
    this.avatarKey,
    this.locale = 'en',
    this.status,
    this.vendor,
  });

  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? displayName;
  final String? avatarKey;
  final String locale;
  final String? status;
  final Map<String, dynamic>? vendor;

  String get fullName => displayName?.isNotEmpty == true ? displayName! : '$firstName $lastName';
}
