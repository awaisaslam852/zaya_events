String localized(dynamic value, String locale) {
  if (value is Map) {
    final code = locale.split(RegExp('[-_]')).first.toLowerCase();
    final catalog = code == 'ar' ? 'ar' : 'en';
    for (final key in [locale, code, catalog, 'en', 'ar']) {
      final preferred = value[key];
      if (preferred is String && preferred.isNotEmpty) {
        return preferred;
      }
    }
  }
  return value?.toString() ?? '';
}

Map<String, String> localizedPair(String en, String ar) => {'en': en, 'ar': ar};

/// UI is translated via app locale. Catalog APIs still require `{en, ar}`.
Map<String, String> catalogText(String value) {
  final text = value.trim();
  return {'en': text, 'ar': text};
}

T? asMapValue<T>(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is T) {
    return value;
  }
  return null;
}
