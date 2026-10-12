import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/usecases/bookings_usecases.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._list, this._get, this._modify, this._cancel, this._payIntent, this._confirmPay)
      : super(const BookingsState());

  final ListBookings _list;
  final GetBookings _get;
  final ModifyBooking _modify;
  final CancelBooking _cancel;
  final CreateBookingPayment _payIntent;
  final ConfirmBookingPayment _confirmPay;

  Future<void> load({Map<String, dynamic>? query}) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _list(query: query);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (page) => emit(state.copyWith(loading: false, items: page.items)),
    );
  }

  Future<void> loadOne(String id) async {
    emit(state.copyWith(loading: true, error: null));
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
      return null;
    });
  }

  Future<String?> cancel(String id) async {
    final result = await _cancel(id);
    return result.fold((f) => f.message, (item) {
      emit(state.copyWith(detail: item));
      return null;
    });
  }

  Future<String?> pay(String bookingId, String kind) async {
    final intent = await _payIntent(bookingId, kind);
    if (intent.isLeft()) {
      return intent.fold((f) => f.message, (_) => null);
    }
    final data = intent.getOrElse((_) => <String, dynamic>{});
    final checkoutUrl = data['checkoutUrl']?.toString();
    final mock = data['mock'] == true;
    final payment = data['payment'] is Map ? Map<String, dynamic>.from(data['payment'] as Map) : <String, dynamic>{};
    final paymentId = payment['id']?.toString();
    if (!mock && checkoutUrl != null && checkoutUrl.isNotEmpty) {
      await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      await loadOne(bookingId);
      return null;
    }
    if (paymentId == null || paymentId.isEmpty) {
      return 'Payment did not start';
    }
    final confirmed = await _confirmPay(paymentId);
    if (confirmed.isLeft()) {
      return confirmed.fold((f) => f.message, (_) => null);
    }
    final row = confirmed.getOrElse((_) => <String, dynamic>{});
    await loadOne(bookingId);
    final invoice = row['invoice'];
    if (invoice is Map && invoice['invoiceNumber'] != null) {
      return 'OK:${invoice['invoiceNumber']}';
    }
    return 'OK';
  }
}
