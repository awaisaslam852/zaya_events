import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(SharedPreferences prefs) : this.fromStored(prefs.getString('locale') ?? 'en', prefs);

  LocaleCubit.fromStored(String code, [this._prefs]) : super(Locale(code));

  final SharedPreferences? _prefs;

  Future<void> setLocale(String code) async {
    await _prefs?.setString('locale', code);
    emit(Locale(code));
  }
}
