import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/vendors_item.dart';

part 'vendors_state.freezed.dart';

@freezed
abstract class VendorsState with _$VendorsState {
  const factory VendorsState({
    @Default(false) bool loading,
    String? error,
    @Default(<VendorsItem>[]) List<VendorsItem> items,
    VendorsItem? detail,
  }) = _VendorsState;
}
