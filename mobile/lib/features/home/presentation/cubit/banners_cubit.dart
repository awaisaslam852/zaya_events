import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../data/banners_repository.dart';

class BannersState {
  const BannersState({this.items = const [], this.loading = false});
  final List<Map<String, dynamic>> items;
  final bool loading;
}

class BannersCubit extends SafeCubit<BannersState> {
  BannersCubit(this._repo) : super(const BannersState());
  final BannersRepository _repo;

  Future<void> load({Set<String>? placements}) async {
    emit(const BannersState(loading: true));
    final result = await _repo.list(placements: placements ?? BannersRepository.customerPlacements);
    result.fold(
      (_) => emit(const BannersState()),
      (items) => emit(BannersState(items: items)),
    );
  }
}
