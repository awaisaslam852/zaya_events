import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../domain/vendor_dashboard_usecases.dart';

part 'vendor_dashboard_cubit.freezed.dart';

@freezed
abstract class VendorDashboardState with _$VendorDashboardState {
  const factory VendorDashboardState({
    @Default(false) bool loading,
    String? error,
    Map<String, dynamic>? me,
    Map<String, dynamic>? earnings,
    Map<String, dynamic>? reviews,
  }) = _VendorDashboardState;
}

class VendorDashboardCubit extends SafeCubit<VendorDashboardState> {
  VendorDashboardCubit(this._me, this._earnings, this._reviews, this._update)
    : super(const VendorDashboardState());

  final GetVendorMe _me;
  final GetVendorEarnings _earnings;
  final GetVendorReviews _reviews;
  final UpdateVendorProfile _update;

  Future<void> load({bool silent = false}) async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(loading: !silent && state.me == null, error: null));
    final me = await _me();
    final earnings = await _earnings();
    final reviews = await _reviews();
    if (isClosed) {
      return;
    }
    me.fold((f) => emit(state.copyWith(loading: false, error: f.message)), (
      data,
    ) {
      Map<String, dynamic>? earn;
      Map<String, dynamic>? rev;
      earnings.fold((_) {}, (value) => earn = value);
      reviews.fold((_) {}, (value) => rev = value);
      emit(
        state.copyWith(loading: false, me: data, earnings: earn, reviews: rev),
      );
    });
  }

  Future<void> loadReviews() async {
    final result = await _reviews();
    if (isClosed) {
      return;
    }
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (data) => emit(state.copyWith(reviews: data)),
    );
  }

  Future<String?> saveProfile(Map<String, dynamic> body) async {
    final result = await _update(body);
    if (isClosed) {
      return result.fold((f) => f.message, (_) => null);
    }
    return result.fold((f) => f.message, (data) {
      emit(state.copyWith(me: data));
      AppRefresh.instance.ping(AppRefreshTopic.vendorDashboard);
      return null;
    });
  }
}
