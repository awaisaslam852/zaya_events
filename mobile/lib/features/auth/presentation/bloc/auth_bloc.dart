import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/app_role.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required RestoreSessionUseCase restore,
    required LogoutUseCase logout,
    required SocketService sockets,
  }) : _login = login,
       _register = register,
       _restore = restore,
       _logout = logout,
       _sockets = sockets,
       super(const AuthState.unknown()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        started: (_) => _onStarted(emit),
        login: (e) async {
          emit(const AuthState.busy());
          final result = await _login(LoginParams(email: e.email, password: e.password));
          await result.fold(
            (failure) async => emit(AuthState.unauthenticated(message: failure.message)),
            (session) async {
              await _sockets.connect();
              emit(_fromUser(session.user));
            },
          );
        },
        register: (e) async {
          emit(const AuthState.busy());
          final result = await _register(
            RegisterParams(
              email: e.email,
              password: e.password,
              firstName: e.firstName,
              lastName: e.lastName,
              role: e.role,
              country: e.country,
              phone: e.phone,
              locale: e.locale ?? 'en',
              businessNameEn: e.businessNameEn,
              businessNameAr: e.businessNameAr,
              city: e.city,
              legalName: e.legalName,
              taxId: e.taxId,
              website: e.website,
              avatarPath: e.avatarPath,
              avatarName: e.avatarName,
            ),
          );
          await result.fold(
            (failure) async => emit(AuthState.unauthenticated(message: failure.message)),
            (session) async {
              await _sockets.connect();
              emit(_fromUser(session.user));
            },
          );
        },
        logout: (_) => _onLogout(emit),
        userUpdated: (_) => _onStarted(emit),
      );
    });
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final RestoreSessionUseCase _restore;
  final LogoutUseCase _logout;
  final SocketService _sockets;

  AuthState _fromUser(UserEntity user) {
    final role = parseAppRole(user.role);
    if (role == AppRole.admin) {
      return AuthState.adminRedirect(user);
    }
    return AuthState.authenticated(user);
  }

  Future<void> _onStarted(Emitter<AuthState> emit) async {
    try {
      final result = await _restore(const NoParams()).timeout(const Duration(seconds: 8));
      await result.fold(
        (_) async => emit(const AuthState.unauthenticated()),
        (session) async {
          if (session == null) {
            emit(const AuthState.unauthenticated());
            return;
          }
          await _sockets.connect();
          emit(_fromUser(session.user));
        },
      );
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    await _logout(const NoParams());
    await _sockets.disconnect();
    emit(const AuthState.unauthenticated());
  }
}
