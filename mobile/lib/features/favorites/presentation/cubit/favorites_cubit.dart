import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../domain/entities/favorites_item.dart';
import '../../domain/usecases/favorites_usecases.dart';
import 'favorites_state.dart';

class FavoritesCubit extends SafeCubit<FavoritesState> {
  FavoritesCubit(this._list, this._get, this._remove) : super(const FavoritesState());

  final ListFavorites _list;
  final GetFavorites _get;
  final RemoveFavorite _remove;

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

  Future<void> loadOne(String id) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _get(id);
    result.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (item) => emit(state.copyWith(loading: false, detail: item)),
    );
  }

  Future<String?> removeItem(FavoritesItem item) async {
    final type = item.raw['resourceType']?.toString();
    final resourceId = item.raw['resourceId']?.toString() ?? item.raw['providerRef']?.toString();
    if (type == null || resourceId == null) {
      return null;
    }
    final previous = state.items;
    emit(state.copyWith(items: previous.where((row) => row.id != item.id).toList()));
    final result = await _remove(resourceType: type, resourceId: resourceId);
    return result.fold((failure) {
      emit(state.copyWith(items: previous, error: failure.message));
      return failure.message;
    }, (_) {
      AppRefresh.instance.afterFavorite();
      return null;
    });
  }
}
