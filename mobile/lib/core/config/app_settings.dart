import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

class AppSettings {
  String currency = 'AED';
  String siteName = 'Zaya Events';

  Future<void> refresh(ApiClient client) async {
    final result = await client.get<Map<String, dynamic>>(
      '/settings/public',
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
    result.fold((_) {}, (map) {
      currency = map['currency']?.toString() ?? currency;
      siteName = map['siteName']?.toString() ?? siteName;
    });
  }
}

String appCurrency({String? fallback}) {
  if (fallback != null && fallback.isNotEmpty) {
    return fallback;
  }
  if (GetIt.I.isRegistered<AppSettings>()) {
    return GetIt.I<AppSettings>().currency;
  }
  return 'AED';
}
