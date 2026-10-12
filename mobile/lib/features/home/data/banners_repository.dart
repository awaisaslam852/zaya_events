import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';

class BannersRepository {
  BannersRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, List<Map<String, dynamic>>>> homeHero() {
    return _client.get(
      '/banners',
      query: {'pageSize': 20},
      parse: (data) {
        const home = {'HOME_HERO', 'HOME_SECONDARY', 'DISCOVERY'};
        final map = Map<String, dynamic>.from(data as Map);
        return (map['items'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where((row) => home.contains(row['placement']?.toString()))
            .toList();
      },
    );
  }
}
