import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zaya_events/core/error/failures.dart';
import 'package:zaya_events/core/pagination/paginated.dart';
import 'package:zaya_events/features/venues/domain/entities/venues_item.dart';
import 'package:zaya_events/features/venues/domain/repositories/venues_repository.dart';
import 'package:zaya_events/features/venues/domain/usecases/venues_usecases.dart';
import 'package:zaya_events/features/venues/presentation/cubit/venues_cubit.dart';
import 'package:zaya_events/features/venues/presentation/pages/venues_list_page.dart';

import 'support/test_app.dart';

class _FakeVenuesRepository implements VenuesRepository {
  @override
  Future<Either<Failure, VenuesItem>> getById(String id) async =>
      Right(VenuesItem({'id': id, 'name': const {'en': 'One', 'ar': 'واحد'}}));

  @override
  Future<Either<Failure, Map<String, dynamic>>> inquire(String id, Map<String, dynamic> body) async =>
      const Right(<String, dynamic>{});

  @override
  Future<Either<Failure, Paginated<VenuesItem>>> list({int page = 1, Map<String, dynamic>? query}) async {
    return Right(
      Paginated(
        items: [
          VenuesItem({
            'id': 'venue-1',
            'name': {'en': 'Palm Hall', 'ar': 'قاعة النخيل'},
            'city': 'Dubai',
          }),
        ],
        total: 1,
        page: page,
        pageSize: 20,
      ),
    );
  }
}

void main() {
  testWidgets('venue list renders localized titles', (tester) async {
    final cubit = VenuesCubit(ListVenues(_FakeVenuesRepository()), GetVenues(_FakeVenuesRepository()));
    await cubit.load();
    await tester.pumpWidget(testApp(child: VenuesListPage(cubit: cubit)));
    await tester.pump();
    expect(find.text('Venues'), findsOneWidget);
    expect(find.text('Palm Hall'), findsOneWidget);
    expect(find.text('Dubai'), findsOneWidget);
  });
}
