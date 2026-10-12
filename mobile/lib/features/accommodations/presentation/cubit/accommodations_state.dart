import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/accommodations_item.dart';

part 'accommodations_state.freezed.dart';

@freezed
abstract class AccommodationsState with _$AccommodationsState {
  const factory AccommodationsState({
    @Default(false) bool loading,
    String? error,
    @Default(<AccommodationsItem>[]) List<AccommodationsItem> items,
    AccommodationsItem? detail,
  }) = _AccommodationsState;
}
