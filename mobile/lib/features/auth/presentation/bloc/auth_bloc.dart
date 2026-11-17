import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/auth/app_role.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/config/app_settings.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/push_bootstrap.dart';
import '../../../../core/realtime/socket_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../cart/cart_cubit.dart';
import '../../../notifications/presentation/cubit/unread_notifications_cubit.dart';
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
            (failure) async {
              lastAuthFailure = failure;
              emit(AuthState.unauthenticated(message: failure.message));
            },
            (session) async {
              lastAuthFailure = null;
              emit(_fromUser(session.user));
              _refreshUnread();
              await _afterSignIn(session.user);
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
            (failure) async {
              lastAuthFailure = failure;
              emit(AuthState.unauthenticated(message: failure.message));
            },
            (session) async {
              lastAuthFailure = null;
              emit(_fromUser(session.user));
              _refreshUnread();
              await _afterSignIn(session.user);
            },
          );
        },
        logout: (_) async {
          final signedIn = state.maybeWhen(
            authenticated: (_) => true,
            adminRedirect: (_) => true,
            orElse: () => false,
          );
          if (!signedIn) {
            return;
          }
          await _onLogout(emit);
        },
        userUpdated: (_) => _onStarted(emit),
      );
    });
  }

  Failure? lastAuthFailure;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final RestoreSessionUseCase _restore;
  final LogoutUseCase _logout;
  final SocketService _sockets;

  Future<void> _afterSignIn(UserEntity user) async {
    try {
      await _sockets.connect();
      await _syncCountrySettings(user);
      await _registerPushToken();
    } catch (_) {}
  }

  Future<void> _syncCountrySettings(UserEntity user) async {
    final sl = GetIt.I;
    if (sl.isRegistered<AppSettings>() && sl.isRegistered<ApiClient>()) {
      await sl<AppSettings>().refresh(sl<ApiClient>(), country: user.country);
    }
  }

  Future<void> _registerPushToken() async {
    final sl = GetIt.I;
    if (sl.isRegistered<PushBootstrap>()) {
      await sl<PushBootstrap>().registerCurrentToken();
    }
  }

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
        (_) async {
          lastAuthFailure = null;
          emit(const AuthState.unauthenticated());
        },
        (session) async {
          if (session == null) {
            lastAuthFailure = null;
            emit(const AuthState.unauthenticated());
            return;
          }
          emit(_fromUser(session.user));
          _refreshUnread();
          await _afterSignIn(session.user);
        },
      );
    } catch (_) {
      lastAuthFailure = null;
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogout(Emitter<AuthState> emit) async {
    await _logout(const NoParams());
    await _sockets.disconnect();
    if (GetIt.I.isRegistered<CartCubit>()) {
      GetIt.I<CartCubit>().reset();
    }
    if (GetIt.I.isRegistered<UnreadNotificationsCubit>()) {
      GetIt.I<UnreadNotificationsCubit>().reset();
    }
    lastAuthFailure = null;
    emit(const AuthState.unauthenticated());
  }

  void _refreshUnread() {
    if (GetIt.I.isRegistered<UnreadNotificationsCubit>()) {
      GetIt.I<UnreadNotificationsCubit>().refresh();
    }
  }
}
