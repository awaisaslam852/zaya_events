import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/notifications/push_bootstrap.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/calls/presentation/bloc/call_bloc.dart';
import 'features/calls/presentation/bloc/call_event.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';

/// Paints a first frame immediately so `flutter run` can attach the VM service
/// on physical devices, then loads DI / Firebase in the background.
class ZayaStartupApp extends StatefulWidget {
  const ZayaStartupApp({super.key});

  @override
  State<ZayaStartupApp> createState() => _ZayaStartupAppState();
}

class _ZayaStartupAppState extends State<ZayaStartupApp> {
  Widget? _app;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await bootstrapServices();
      if (!mounted) {
        return;
      }
      setState(() {
        _app = MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<AuthBloc>()),
            BlocProvider.value(value: sl<CallBloc>()),
            BlocProvider.value(value: sl<LocaleCubit>()),
          ],
          child: const ZayaApp(),
        );
      });
    } catch (error, stack) {
      debugPrint('Zaya startup failed: $error\n$stack');
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = _app;
    if (app != null) {
      return app;
    }
    final error = _error;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: error == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Startup failed:\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );
  }
}

Future<void> bootstrapServices() async {
  await configureDependencies();
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 3));
  } catch (_) {}
  try {
    await sl<PushBootstrap>().init().timeout(const Duration(seconds: 3));
  } catch (_) {}
  sl<AuthBloc>().add(const AuthEvent.started());
  sl<CallBloc>().add(const CallEvent.started());
}
