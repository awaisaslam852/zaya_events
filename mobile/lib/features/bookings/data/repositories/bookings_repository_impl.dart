import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';
import '../../domain/entities/bookings_item.dart';
import '../../domain/repositories/bookings_repository.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  BookingsRepositoryImpl(this._client);
  final ApiClient _client;

  Paginated<BookingsItem> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? [])
        .map((e) => BookingsItem(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }

  @override
  Future<Either<Failure, Paginated<BookingsItem>>> list({int page = 1, Map<String, dynamic>? query}) {
    return _client.get('/bookings', query: {'page': page, ...?query}, parse: _page);
  }

  @override
  Future<Either<Failure, BookingsItem>> getById(String id) {
    return _client.get('/bookings/$id', parse: (data) => BookingsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, BookingsItem>> modify(String id, Map<String, dynamic> body) {
    return _client.patch('/bookings/$id', data: body, parse: (data) => BookingsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, BookingsItem>> cancel(String id) {
    return _client.post('/bookings/$id/cancel', data: {}, parse: (data) => BookingsItem(Map<String, dynamic>.from(data as Map)));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createPaymentIntent(String bookingId, String kind) {
    return _client.post(
      '/payments/intent',
      data: {'bookingId': bookingId, 'kind': kind},
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> confirmPayment(String paymentId) {
    return _client.post(
      '/payments/$paymentId/confirm',
      data: {},
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }
}
