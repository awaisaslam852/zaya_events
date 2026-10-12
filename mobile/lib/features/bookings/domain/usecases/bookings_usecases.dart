import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/pagination/paginated.dart';
import '../entities/bookings_item.dart';
import '../repositories/bookings_repository.dart';

class ListBookings {
  ListBookings(this._repository);
  final BookingsRepository _repository;
  Future<Either<Failure, Paginated<BookingsItem>>> call({int page = 1, Map<String, dynamic>? query}) =>
      _repository.list(page: page, query: query);
}

class GetBookings {
  GetBookings(this._repository);
  final BookingsRepository _repository;
  Future<Either<Failure, BookingsItem>> call(String id) => _repository.getById(id);
}

class ModifyBooking {
  ModifyBooking(this._repository);
  final BookingsRepository _repository;
  Future<Either<Failure, BookingsItem>> call(String id, Map<String, dynamic> body) => _repository.modify(id, body);
}

class CancelBooking {
  CancelBooking(this._repository);
  final BookingsRepository _repository;
  Future<Either<Failure, BookingsItem>> call(String id) => _repository.cancel(id);
}

class CreateBookingPayment {
  CreateBookingPayment(this._repository);
  final BookingsRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String bookingId, String kind) =>
      _repository.createPaymentIntent(bookingId, kind);
}

class ConfirmBookingPayment {
  ConfirmBookingPayment(this._repository);
  final BookingsRepository _repository;
  Future<Either<Failure, Map<String, dynamic>>> call(String paymentId) => _repository.confirmPayment(paymentId);
}
