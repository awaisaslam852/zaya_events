import 'package:shared_preferences/shared_preferences.dart';

class IntroPrefs {
  static const key = 'intro_completed';

  static bool seen(SharedPreferences prefs) => prefs.getBool(key) ?? false;

  static Future<void> complete(SharedPreferences prefs) => prefs.setBool(key, true);
}
