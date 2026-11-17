import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/i18n/app_languages.dart';
import 'app_localizations.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Loads Arabic or English UI copy for every device locale in [AppLanguages].
/// Dates, dialogs, and direction still follow the chosen locale via Material.
class ZayaLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const ZayaLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLanguages.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    if (locale.languageCode == 'ar') {
      return SynchronousFuture<AppLocalizations>(AppLocalizationsAr());
    }
    return SynchronousFuture<AppLocalizations>(AppLocalizationsEn(locale.toString()));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

class FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final supported = GlobalMaterialLocalizations.delegate.isSupported(locale) ? locale : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(supported);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final supported = GlobalCupertinoLocalizations.delegate.isSupported(locale) ? locale : const Locale('en');
    return GlobalCupertinoLocalizations.delegate.load(supported);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}

class FallbackWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) => GlobalWidgetsLocalizations.delegate.load(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) => false;
}
