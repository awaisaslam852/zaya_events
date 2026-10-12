import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/bookings_item.dart';

abstract class BookingsRepository {
  Future<Either<Failure, Paginated<BookingsItem>>> list({int page = 1, Map<String, dynamic>? query});
  Future<Either<Failure, BookingsItem>> getById(String id);
  Future<Either<Failure, BookingsItem>> modify(String id, Map<String, dynamic> body);
  Future<Either<Failure, BookingsItem>> cancel(String id);
  Future<Either<Failure, Map<String, dynamic>>> createPaymentIntent(String bookingId, String kind);
  Future<Either<Failure, Map<String, dynamic>>> confirmPayment(String paymentId);
}
