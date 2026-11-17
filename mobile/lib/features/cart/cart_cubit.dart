import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../core/sync/app_refresh.dart';
import 'cart_repository.dart';
import 'cart_totals.dart';

class CartState {
  const CartState({
    this.loading = false,
    this.checkingOut = false,
    this.error,
    this.items = const [],
    this.subtotal = 0,
    this.depositTotal = 0,
    this.currency = 'AED',
  });

  final bool loading;
  final bool checkingOut;
  final String? error;
  final List<Map<String, dynamic>> items;
  final num subtotal;
  final num depositTotal;
  final String currency;

  int get count => items.length;

  CartState copyWith({
    bool? loading,
    bool? checkingOut,
    String? error,
    bool clearError = false,
    List<Map<String, dynamic>>? items,
    num? subtotal,
    num? depositTotal,
    String? currency,
  }) {
    return CartState(
      loading: loading ?? this.loading,
      checkingOut: checkingOut ?? this.checkingOut,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      depositTotal: depositTotal ?? this.depositTotal,
      currency: currency ?? this.currency,
    );
  }
}

class CartCubit extends SafeCubit<CartState> {
  CartCubit(this._repo) : super(const CartState());

  final CartRepository _repo;
  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded || state.loading) {
      return;
    }
    await load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, clearError: true));
    }
    final result = await _repo.list();
    result.fold(
      (failure) => emit(state.copyWith(loading: false, error: failure.message)),
      (data) {
        _loaded = true;
        emit(_fromPayload(data));
      },
    );
  }

  CartState _fromPayload(Map<String, dynamic> data) {
    final items = (data['items'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final totals = CartTotals(items: items);
    return CartState(
      items: items,
      subtotal: num.tryParse('${data['subtotal'] ?? totals.subtotal}') ?? totals.subtotal,
      depositTotal: num.tryParse('${data['depositTotal'] ?? totals.deposit}') ?? totals.deposit,
      currency: data['currency']?.toString() ?? totals.currency,
    );
  }

  void reset() {
    _loaded = false;
    emit(const CartState());
  }

  Future<String?> add(Map<String, dynamic> body) async {
    final result = await _repo.add(body);
    if (result.isLeft()) {
      return result.fold((failure) => failure.message, (_) => null);
    }
    await load();
    AppRefresh.instance.afterCart();
    return null;
  }

  Future<void> remove(String id) async {
    emit(state.copyWith(loading: true, clearError: true));
    final result = await _repo.remove(id);
    await result.fold((failure) async {
      emit(state.copyWith(loading: false, error: failure.message));
    }, (_) async {
      await load();
      AppRefresh.instance.afterCart();
    });
  }

  Future<String?> checkout({String? eventId}) async {
    emit(state.copyWith(checkingOut: true, clearError: true));
    final result = await _repo.checkout(eventId: eventId);
    if (result.isLeft()) {
      final message = result.fold((failure) => failure.message, (_) => null);
      emit(state.copyWith(checkingOut: false, error: message));
      return message;
    }
    final data = result.getOrElse((_) => <String, dynamic>{});
    await load();
    AppRefresh.instance.afterCheckout();
    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      return first is Map ? first['message']?.toString() : 'Some items could not be booked';
    }
    return null;
  }
}
