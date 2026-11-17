import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/i18n/app_languages.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(SharedPreferences prefs)
      : this.fromStored(_initialTag(prefs), prefs);

  LocaleCubit.fromStored(String tag, [this._prefs]) : super(AppLanguages.byTag(tag).locale);

  final SharedPreferences? _prefs;

  AppLanguage get current => AppLanguages.byLocale(state);

  Future<void> setLocale(String tag) async {
    final language = AppLanguages.byTag(tag);
    await _prefs?.setString('locale', language.tag);
    emit(language.locale);
  }

  static String _initialTag(SharedPreferences prefs) {
    final stored = prefs.getString('locale');
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    final device = SchedulerBinding.instance.platformDispatcher.locale;
    return AppLanguages.byLocale(device).tag;
  }
}
