import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';

class BannersRepository {
  BannersRepository(this._client);
  final ApiClient _client;

  static const customerPlacements = {'HOME_HERO', 'HOME_SECONDARY', 'DISCOVERY'};
  static const vendorPlacements = {
    'VENDOR_DASHBOARD',
    'HOME_HERO',
    'HOME_SECONDARY',
    'DISCOVERY',
  };

  Future<Either<Failure, List<Map<String, dynamic>>>> homeHero() {
    return list(placements: customerPlacements);
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> list({
    Set<String> placements = customerPlacements,
  }) {
    return _client.get(
      '/banners',
      query: {'pageSize': 20},
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        final items = (map['items'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where((row) => placements.contains(row['placement']?.toString()))
            .toList();
        items.sort((a, b) {
          final byPlace = _placementRank(a['placement']?.toString()).compareTo(
            _placementRank(b['placement']?.toString()),
          );
          if (byPlace != 0) {
            return byPlace;
          }
          return ((a['sortOrder'] as num?) ?? 0).compareTo((b['sortOrder'] as num?) ?? 0);
        });
        return items;
      },
    );
  }

  static int _placementRank(String? placement) {
    return switch (placement) {
      'VENDOR_DASHBOARD' => 0,
      'HOME_HERO' => 1,
      'HOME_SECONDARY' => 2,
      'DISCOVERY' => 3,
      _ => 9,
    };
  }
}
