import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../core/sync/app_refresh.dart';
import 'vendor_catalog_kind.dart';
import 'vendor_catalog_repository.dart';

class VendorCatalogState {
  const VendorCatalogState({
    this.kind = VendorCatalogKind.all,
    this.loading = false,
    this.error,
    this.items = const [],
    this.detail,
  });

  final VendorCatalogKind kind;
  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? detail;

  VendorCatalogState copyWith({
    VendorCatalogKind? kind,
    bool? loading,
    String? error,
    List<Map<String, dynamic>>? items,
    Map<String, dynamic>? detail,
    bool clearError = false,
    bool clearDetail = false,
  }) {
    return VendorCatalogState(
      kind: kind ?? this.kind,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      items: items ?? this.items,
      detail: clearDetail ? null : detail ?? this.detail,
    );
  }
}

class VendorCatalogCubit extends SafeCubit<VendorCatalogState> {
  VendorCatalogCubit(this._repo) : super(const VendorCatalogState());

  final VendorCatalogRepository _repo;

  Future<void> load(VendorCatalogKind kind, {bool silent = false}) async {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        kind: kind,
        loading: !silent,
        clearError: true,
        clearDetail: !silent,
        items: silent ? state.items : const [],
      ),
    );
    final result = await _repo.list(kind);
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (page) => emit(
        state.copyWith(loading: false, items: page.items, clearError: true),
      ),
    );
  }

  Future<void> loadOne(VendorCatalogKind kind, String id) async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(kind: kind, loading: true, clearError: true));
    final result = await _repo.getById(kind, id);
    if (isClosed) {
      return;
    }
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (item) =>
          emit(state.copyWith(loading: false, detail: item, clearError: true)),
    );
  }

  Future<String?> save({
    required VendorCatalogKind kind,
    String? id,
    required Map<String, dynamic> body,
  }) async {
    final result = id == null
        ? await _repo.create(kind, body)
        : await _repo.update(kind, id, body);
    return result.fold((failure) => failure.message, (_) {
      AppRefresh.instance.afterVendorCatalog();
      return null;
    });
  }

  Future<String?> setPublished(
    VendorCatalogKind kind,
    String id,
    bool published,
  ) async {
    final view = state.kind;
    final result = await _repo.update(kind, id, {'isPublished': published});
    final error = result.fold((failure) => failure.message, (_) => null);
    if (error == null) {
      AppRefresh.instance.afterVendorCatalog();
      await load(view, silent: true);
    }
    return error;
  }

  Future<String?> remove(VendorCatalogKind kind, String id) async {
    final view = state.kind;
    final result = await _repo.remove(kind, id);
    final error = result.fold((failure) => failure.message, (_) => null);
    if (error == null) {
      AppRefresh.instance.afterVendorCatalog();
      await load(view, silent: true);
    }
    return error;
  }
}
