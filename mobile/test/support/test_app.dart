import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaya_events/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:zaya_events/l10n/app_localizations.dart';

Widget testApp({required Widget child}) {
  return BlocProvider(
    create: (_) => LocaleCubit.fromStored('en'),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
