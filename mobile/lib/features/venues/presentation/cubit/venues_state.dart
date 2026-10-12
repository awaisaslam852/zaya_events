import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/venues_item.dart';

part 'venues_state.freezed.dart';

@freezed
abstract class VenuesState with _$VenuesState {
  const factory VenuesState({
    @Default(false) bool loading,
    String? error,
    @Default(<VenuesItem>[]) List<VenuesItem> items,
    VenuesItem? detail,
  }) = _VenuesState;
}
