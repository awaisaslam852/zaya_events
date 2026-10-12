import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/listings_usecases.dart';

part 'listings_cubit.freezed.dart';

@freezed
abstract class ListingsState with _$ListingsState {
  const factory ListingsState({
    @Default(false) bool loading,
    String? error,
    @Default([]) List<Map<String, dynamic>> items,
    Map<String, dynamic>? detail,
  }) = _ListingsState;
}

class ListingsCubit extends Cubit<ListingsState> {
  ListingsCubit(this._list, this._get, this._create, this._update, this._delete) : super(const ListingsState());

  final ListVendorListings _list;
  final GetListing _get;
  final CreateListing _create;
  final UpdateListing _update;
  final DeleteListing _delete;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _list();
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

  Future<String?> save({String? id, required Map<String, dynamic> body}) async {
    emit(state.copyWith(error: null));
    final result = id == null ? await _create(body) : await _update(id, body);
    return result.fold((f) {
      emit(state.copyWith(error: f.message));
      return f.message;
    }, (_) => null);
  }

  Future<void> create(Map<String, dynamic> body) async {
    await save(body: body);
    await load();
  }

  Future<void> patch(String id, Map<String, dynamic> body) async {
    await save(id: id, body: body);
    await load();
  }

  Future<void> remove(String id) async {
    await _delete(id);
    await load();
  }
}
