String localized(dynamic value, String locale) {
  if (value is Map) {
    final preferred = value[locale];
    if (preferred is String && preferred.isNotEmpty) {
      return preferred;
    }
    final en = value['en'];
    final ar = value['ar'];
    if (en is String && en.isNotEmpty) {
      return en;
    }
    if (ar is String && ar.isNotEmpty) {
      return ar;
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
