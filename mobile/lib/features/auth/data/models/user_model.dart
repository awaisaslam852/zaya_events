import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String role,
    required String firstName,
    required String lastName,
    String? phone,
    String? displayName,
    String? avatarKey,
    @Default('en') String locale,
    String? status,
    Map<String, dynamic>? vendor,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
