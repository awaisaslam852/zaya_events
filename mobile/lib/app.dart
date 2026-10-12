import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/calls/presentation/bloc/call_bloc.dart';
import 'features/calls/presentation/bloc/call_state.dart';
import 'features/calls/presentation/pages/incoming_call_page.dart';
import 'features/settings/presentation/cubit/locale_cubit.dart';
import 'l10n/app_localizations.dart';

class ZayaApp extends StatelessWidget {
  const ZayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return BlocListener<CallBloc, CallState>(
          listenWhen: (prev, next) =>
              next.incoming != null && prev.incoming?.id != next.incoming?.id,
          listener: (context, state) {
            final incoming = state.incoming;
            if (incoming == null) {
              return;
            }
            showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.black87,
              pageBuilder: (_, _, _) => IncomingCallPage(call: incoming),
            );
          },
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
