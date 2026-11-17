import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../booking_requests/domain/booking_requests_usecases.dart';
import '../../../payments/payment_checkout_args.dart';
import '../../domain/entities/bookings_item.dart';
import '../../domain/usecases/bookings_usecases.dart';
import 'bookings_state.dart';

class PayStart {
  const PayStart._({this.error, this.receipt, this.checkout});
  const PayStart.error(String message) : this._(error: message);
  const PayStart.done([this.receipt]) : error = null, checkout = null;
  const PayStart.checkout(PaymentCheckoutArgs this.checkout) : error = null, receipt = null;

  final String? error;
  final String? receipt;
  final PaymentCheckoutArgs? checkout;
}

class BookingsCubit extends SafeCubit<BookingsState> {
  BookingsCubit(
    this._list,
    this._get,
    this._modify,
    this._cancel,
    this._payIntent,
    this._confirmPay,
    this._transition,
    this._review,
  ) : super(const BookingsState());

  final ListBookings _list;
  final GetBookings _get;
  final ModifyBooking _modify;
  final CancelBooking _cancel;
  final CreateBookingPayment _payIntent;
  final ConfirmBookingPayment _confirmPay;
  final TransitionBooking _transition;
  final CreateBookingReview _review;

  Future<void> load({Map<String, dynamic>? query, bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, error: null));
    }
    final result = await _list(query: query);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, error: null, items: page.items)),
    );
  }

  Future<void> loadOne(String id, {bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, error: null));
    }
    final result = await _get(id);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (item) => emit(state.copyWith(loading: false, detail: item)),
    );
  }

  Future<String?> modify(String id, Map<String, dynamic> body) async {
    final result = await _modify(id, body);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      AppRefresh.instance.afterBooking();
      return null;
    });
  }

  Future<String?> submitReview(String id, {required int rating, String? comment}) async {
    final result = await _review(id, {
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
    final error = result.fold((f) => f.message, (_) => null);
    if (error != null) {
      return error;
    }
    await loadOne(id, silent: true);
    AppRefresh.instance.afterBooking();
    return null;
  }

  Future<String?> vendorAct(String id, String action) async {
    final result = await _transition(id, action);
    return result.fold((f) => f.message, (row) {
      emit(state.copyWith(detail: BookingsItem(row)));
      AppRefresh.instance.afterBooking();
      return null;
    });
  }

  Future<String?> cancel(String id) async {
    final result = await _cancel(id);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      AppRefresh.instance.afterBooking();
      return null;
    });
  }

  Future<PayStart> startPay(String bookingId, String kind, {String? title}) async {
    final intent = await _payIntent(bookingId, kind);
    if (intent.isLeft()) {
      return PayStart.error(intent.fold((f) => f.message, (_) => 'Payment did not start'));
    }
    final data = intent.getOrElse((_) => <String, dynamic>{});
    final mock = data['mock'] == true;
    final payment = data['payment'] is Map ? Map<String, dynamic>.from(data['payment'] as Map) : <String, dynamic>{};
    final paymentId = payment['id']?.toString();
    if (mock) {
      if (paymentId == null || paymentId.isEmpty) {
        return const PayStart.error('Payment did not start');
      }
      return _finishConfirm(bookingId, paymentId);
    }
    final checkout = PaymentCheckoutArgs.fromIntent(bookingId: bookingId, data: data, title: title);
    if (!checkout.isReady) {
      return const PayStart.error('Card checkout is not configured');
    }
    return PayStart.checkout(checkout);
  }

  Future<String?> confirmAfterCard(String bookingId, String paymentId) async {
    final result = await _finishConfirm(bookingId, paymentId);
    return result.error ?? result.receipt;
  }

  Future<PayStart> _finishConfirm(String bookingId, String paymentId) async {
    final confirmed = await _confirmPay(paymentId);
    if (confirmed.isLeft()) {
      return PayStart.error(confirmed.fold((f) => f.message, (_) => 'Payment failed'));
    }
    final row = confirmed.getOrElse((_) => <String, dynamic>{});
    await loadOne(bookingId, silent: true);
    AppRefresh.instance.afterBooking();
    final invoice = row['invoice'];
    if (invoice is Map && invoice['invoiceNumber'] != null) {
      return PayStart.done('OK:${invoice['invoiceNumber']}');
    }
    return const PayStart.done('OK');
  }
}
