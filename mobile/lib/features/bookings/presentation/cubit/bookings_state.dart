import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/bookings_item.dart';

part 'bookings_state.freezed.dart';

@freezed
abstract class BookingsState with _$BookingsState {
  const factory BookingsState({
    @Default(false) bool loading,
    String? error,
    @Default(<BookingsItem>[]) List<BookingsItem> items,
    BookingsItem? detail,
  }) = _BookingsState;
}
