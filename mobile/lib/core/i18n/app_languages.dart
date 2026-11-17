import 'package:flutter/material.dart';

class AppLanguage {
  const AppLanguage({
    required this.tag,
    required this.englishName,
    required this.nativeName,
  });

  /// BCP-47 tag stored in prefs, e.g. `en`, `ar`, `zh-Hans`, `pt-BR`.
  final String tag;
  final String englishName;
  final String nativeName;

  Locale get locale {
    final parts = tag.split('-');
    if (parts.length == 1) {
      return Locale(parts[0]);
    }
    if (parts[1].length == 4) {
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale.fromSubtags(languageCode: parts[0], countryCode: parts[1]);
  }

  bool get isRtl => const {'ar', 'fa', 'he', 'ps', 'sd', 'ug', 'ur', 'yi'}.contains(locale.languageCode);

  /// Catalog/API still uses `{en, ar}`.
  String get catalogLocale => locale.languageCode == 'ar' ? 'ar' : 'en';
}

abstract final class AppLanguages {
  static const List<AppLanguage> all = [
    AppLanguage(tag: 'af', englishName: 'Afrikaans', nativeName: 'Afrikaans'),
    AppLanguage(tag: 'am', englishName: 'Amharic', nativeName: 'አማርኛ'),
    AppLanguage(tag: 'ar', englishName: 'Arabic', nativeName: 'العربية'),
    AppLanguage(tag: 'hy', englishName: 'Armenian', nativeName: 'Հայերեն'),
    AppLanguage(tag: 'az', englishName: 'Azerbaijani', nativeName: 'Azərbaycan'),
    AppLanguage(tag: 'eu', englishName: 'Basque', nativeName: 'Euskara'),
    AppLanguage(tag: 'be', englishName: 'Belarusian', nativeName: 'Беларуская'),
    AppLanguage(tag: 'bn', englishName: 'Bengali', nativeName: 'বাংলা'),
    AppLanguage(tag: 'bs', englishName: 'Bosnian', nativeName: 'Bosanski'),
    AppLanguage(tag: 'bg', englishName: 'Bulgarian', nativeName: 'Български'),
    AppLanguage(tag: 'my', englishName: 'Burmese', nativeName: 'မြန်မာ'),
    AppLanguage(tag: 'ca', englishName: 'Catalan', nativeName: 'Català'),
    AppLanguage(tag: 'zh-Hans', englishName: 'Chinese (Simplified)', nativeName: '简体中文'),
    AppLanguage(tag: 'zh-Hant', englishName: 'Chinese (Traditional)', nativeName: '繁體中文'),
    AppLanguage(tag: 'hr', englishName: 'Croatian', nativeName: 'Hrvatski'),
    AppLanguage(tag: 'cs', englishName: 'Czech', nativeName: 'Čeština'),
    AppLanguage(tag: 'da', englishName: 'Danish', nativeName: 'Dansk'),
    AppLanguage(tag: 'nl', englishName: 'Dutch', nativeName: 'Nederlands'),
    AppLanguage(tag: 'en', englishName: 'English', nativeName: 'English'),
    AppLanguage(tag: 'et', englishName: 'Estonian', nativeName: 'Eesti'),
    AppLanguage(tag: 'fil', englishName: 'Filipino', nativeName: 'Filipino'),
    AppLanguage(tag: 'fi', englishName: 'Finnish', nativeName: 'Suomi'),
    AppLanguage(tag: 'fr', englishName: 'French', nativeName: 'Français'),
    AppLanguage(tag: 'gl', englishName: 'Galician', nativeName: 'Galego'),
    AppLanguage(tag: 'ka', englishName: 'Georgian', nativeName: 'ქართული'),
    AppLanguage(tag: 'de', englishName: 'German', nativeName: 'Deutsch'),
    AppLanguage(tag: 'el', englishName: 'Greek', nativeName: 'Ελληνικά'),
    AppLanguage(tag: 'gu', englishName: 'Gujarati', nativeName: 'ગુજરાતી'),
    AppLanguage(tag: 'he', englishName: 'Hebrew', nativeName: 'עברית'),
    AppLanguage(tag: 'hi', englishName: 'Hindi', nativeName: 'हिन्दी'),
    AppLanguage(tag: 'hu', englishName: 'Hungarian', nativeName: 'Magyar'),
    AppLanguage(tag: 'is', englishName: 'Icelandic', nativeName: 'Íslenska'),
    AppLanguage(tag: 'id', englishName: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    AppLanguage(tag: 'it', englishName: 'Italian', nativeName: 'Italiano'),
    AppLanguage(tag: 'ja', englishName: 'Japanese', nativeName: '日本語'),
    AppLanguage(tag: 'kn', englishName: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    AppLanguage(tag: 'kk', englishName: 'Kazakh', nativeName: 'Қазақ'),
    AppLanguage(tag: 'km', englishName: 'Khmer', nativeName: 'ខ្មែរ'),
    AppLanguage(tag: 'ko', englishName: 'Korean', nativeName: '한국어'),
    AppLanguage(tag: 'ky', englishName: 'Kyrgyz', nativeName: 'Кыргызча'),
    AppLanguage(tag: 'lo', englishName: 'Lao', nativeName: 'ລາວ'),
    AppLanguage(tag: 'lv', englishName: 'Latvian', nativeName: 'Latviešu'),
    AppLanguage(tag: 'lt', englishName: 'Lithuanian', nativeName: 'Lietuvių'),
    AppLanguage(tag: 'mk', englishName: 'Macedonian', nativeName: 'Македонски'),
    AppLanguage(tag: 'ms', englishName: 'Malay', nativeName: 'Bahasa Melayu'),
    AppLanguage(tag: 'ml', englishName: 'Malayalam', nativeName: 'മലയാളം'),
    AppLanguage(tag: 'mr', englishName: 'Marathi', nativeName: 'मराठी'),
    AppLanguage(tag: 'mn', englishName: 'Mongolian', nativeName: 'Монгол'),
    AppLanguage(tag: 'ne', englishName: 'Nepali', nativeName: 'नेपाली'),
    AppLanguage(tag: 'nb', englishName: 'Norwegian', nativeName: 'Norsk bokmål'),
    AppLanguage(tag: 'or', englishName: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    AppLanguage(tag: 'ps', englishName: 'Pashto', nativeName: 'پښتو'),
    AppLanguage(tag: 'fa', englishName: 'Persian', nativeName: 'فارسی'),
    AppLanguage(tag: 'pl', englishName: 'Polish', nativeName: 'Polski'),
    AppLanguage(tag: 'pt-BR', englishName: 'Portuguese (Brazil)', nativeName: 'Português (Brasil)'),
    AppLanguage(tag: 'pt', englishName: 'Portuguese (Portugal)', nativeName: 'Português'),
    AppLanguage(tag: 'pa', englishName: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    AppLanguage(tag: 'ro', englishName: 'Romanian', nativeName: 'Română'),
    AppLanguage(tag: 'ru', englishName: 'Russian', nativeName: 'Русский'),
    AppLanguage(tag: 'sr', englishName: 'Serbian', nativeName: 'Српски'),
    AppLanguage(tag: 'si', englishName: 'Sinhala', nativeName: 'සිංහල'),
    AppLanguage(tag: 'sk', englishName: 'Slovak', nativeName: 'Slovenčina'),
    AppLanguage(tag: 'sl', englishName: 'Slovenian', nativeName: 'Slovenščina'),
    AppLanguage(tag: 'es', englishName: 'Spanish', nativeName: 'Español'),
    AppLanguage(tag: 'sw', englishName: 'Swahili', nativeName: 'Kiswahili'),
    AppLanguage(tag: 'sv', englishName: 'Swedish', nativeName: 'Svenska'),
    AppLanguage(tag: 'ta', englishName: 'Tamil', nativeName: 'தமிழ்'),
    AppLanguage(tag: 'te', englishName: 'Telugu', nativeName: 'తెలుగు'),
    AppLanguage(tag: 'th', englishName: 'Thai', nativeName: 'ไทย'),
    AppLanguage(tag: 'tr', englishName: 'Turkish', nativeName: 'Türkçe'),
    AppLanguage(tag: 'uk', englishName: 'Ukrainian', nativeName: 'Українська'),
    AppLanguage(tag: 'ur', englishName: 'Urdu', nativeName: 'اردو'),
    AppLanguage(tag: 'uz', englishName: 'Uzbek', nativeName: 'Oʻzbek'),
    AppLanguage(tag: 'vi', englishName: 'Vietnamese', nativeName: 'Tiếng Việt'),
    AppLanguage(tag: 'cy', englishName: 'Welsh', nativeName: 'Cymraeg'),
    AppLanguage(tag: 'zu', englishName: 'Zulu', nativeName: 'isiZulu'),
  ];

  static List<Locale> get locales => all.map((language) => language.locale).toList();

  static final AppLanguage english = all.firstWhere((language) => language.tag == 'en');

  static AppLanguage byTag(String? tag) {
    if (tag == null || tag.isEmpty) {
      return english;
    }
    for (final language in all) {
      if (language.tag.toLowerCase() == tag.toLowerCase()) {
        return language;
      }
    }
    final code = tag.split('-').first.toLowerCase();
    for (final language in all) {
      if (language.locale.languageCode == code) {
        return language;
      }
    }
    return english;
  }

  static AppLanguage byLocale(Locale locale) {
    for (final language in all) {
      final item = language.locale;
      if (item.languageCode == locale.languageCode &&
          item.scriptCode == locale.scriptCode &&
          (item.countryCode == null || item.countryCode == locale.countryCode)) {
        return language;
      }
    }
    return byTag(locale.languageCode);
  }

  static bool isSupported(Locale locale) {
    return all.any((language) => language.locale.languageCode == locale.languageCode);
  }

  static String tagOf(Locale locale) => byLocale(locale).tag;
}
