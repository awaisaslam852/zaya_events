import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.unknown() = _Unknown;
  const factory AuthState.unauthenticated({String? message}) = _Unauthenticated;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.adminRedirect(UserEntity user) = _AdminRedirect;
  const factory AuthState.busy() = _Busy;
}
