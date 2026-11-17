import 'dart:convert';

Map<String, dynamic>? callPayloadMap(dynamic data) {
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
  }
  if (data is List && data.isNotEmpty) {
    return callPayloadMap(data.first);
  }
  return null;
}
