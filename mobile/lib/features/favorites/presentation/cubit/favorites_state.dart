import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/favorites_item.dart';

part 'favorites_state.freezed.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @Default(false) bool loading,
    String? error,
    @Default(<FavoritesItem>[]) List<FavoritesItem> items,
    FavoritesItem? detail,
  }) = _FavoritesState;
}
