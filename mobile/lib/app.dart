import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/i18n/app_languages.dart';
import 'core/notifications/push_bootstrap.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/calls/presentation/bloc/call_bloc.dart';
import 'features/calls/presentation/bloc/call_state.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';
import 'l10n/app_localizations.dart';
import 'l10n/zaya_localizations.dart';

class ZayaApp extends StatefulWidget {
  const ZayaApp({super.key});

  @override
  State<ZayaApp> createState() => _ZayaAppState();
}

class _ZayaAppState extends State<ZayaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPendingIncoming();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _openPendingIncoming();
    }
  }

  Future<void> _openPendingIncoming() async {
    if (!sl.isRegistered<PushBootstrap>()) {
      return;
    }
    await sl<PushBootstrap>().replayPendingIncoming();
    if (!mounted) {
      return;
    }
    _pushIncomingIfNeeded();
  }

  void _pushIncomingIfNeeded() {
    if (!sl.isRegistered<CallBloc>()) {
      return;
    }
    final incoming = sl<CallBloc>().state.incoming;
    if (incoming == null) {
      return;
    }
    final router = AppRouter.router;
    final path = router.routeInformationProvider.value.uri.path;
    if (!path.startsWith('/calls/incoming') && !path.startsWith('/calls/active')) {
      router.push('/calls/incoming', extra: incoming);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLanguages.locales,
      localizationsDelegates: const [
        ZayaLocalizationsDelegate(),
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
      ],
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, next) => prev != next,
          listener: (context, state) {
            state.maybeWhen(
              authenticated: (_) => _pushIncomingIfNeeded(),
              orElse: () {},
            );
          },
          child: BlocListener<CallBloc, CallState>(
            listenWhen: (prev, next) =>
                prev.incoming?.id != next.incoming?.id ||
                (next.active != null && next.token != null && prev.active?.id != next.active?.id),
            listener: (context, state) {
              final router = AppRouter.router;
              final path = router.routeInformationProvider.value.uri.path;
              final incoming = state.incoming;
              if (incoming != null &&
                  !path.startsWith('/calls/incoming') &&
                  !path.startsWith('/calls/active')) {
                router.push('/calls/incoming', extra: incoming);
              }
              if (incoming == null && state.active == null && path.startsWith('/calls/incoming') && router.canPop()) {
                router.pop();
              }
              final active = state.active;
              if (active != null && state.token != null) {
                final route = '/calls/active/${active.id}';
                if (path == route) {
                  return;
                }
                if (path == '/calls/outgoing' || path.startsWith('/calls/incoming')) {
                  router.pushReplacement(route);
                } else {
                  router.push(route);
                }
              }
            },
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
