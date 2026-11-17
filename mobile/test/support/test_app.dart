import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaya_events/core/i18n/app_languages.dart';
import 'package:zaya_events/features/settings/presentation/cubit/locale_cubit.dart';
import 'package:zaya_events/l10n/zaya_localizations.dart';

Widget testApp({required Widget child}) {
  return BlocProvider(
    create: (_) => LocaleCubit.fromStored('en'),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        ZayaLocalizationsDelegate(),
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
        FallbackWidgetsLocalizationsDelegate(),
      ],
      supportedLocales: AppLanguages.locales,
      home: child,
    ),
  );
}
