import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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

class VendorDashboardCubit extends Cubit<VendorDashboardState> {
  VendorDashboardCubit(this._me, this._earnings, this._reviews) : super(const VendorDashboardState());

  final GetVendorMe _me;
  final GetVendorEarnings _earnings;
  final GetVendorReviews _reviews;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    final me = await _me();
    final earnings = await _earnings();
    final reviews = await _reviews();
    me.fold(
      (f) => emit(state.copyWith(loading: false, error: f.message)),
      (data) {
        Map<String, dynamic>? earn;
        Map<String, dynamic>? rev;
        earnings.fold((_) {}, (value) => earn = value);
        reviews.fold((_) {}, (value) => rev = value);
        emit(state.copyWith(loading: false, me: data, earnings: earn, reviews: rev));
      },
    );
  }

  Future<void> loadReviews() async {
    final result = await _reviews();
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (data) => emit(state.copyWith(reviews: data)),
    );
  }
}
