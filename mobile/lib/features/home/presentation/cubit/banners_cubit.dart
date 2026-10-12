import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/banners_repository.dart';

class BannersState {
  const BannersState({this.items = const [], this.loading = false});
  final List<Map<String, dynamic>> items;
  final bool loading;
}

class BannersCubit extends Cubit<BannersState> {
  BannersCubit(this._repo) : super(const BannersState());
  final BannersRepository _repo;

  Future<void> load() async {
    emit(const BannersState(loading: true));
    final result = await _repo.homeHero();
    result.fold(
      (_) => emit(const BannersState()),
      (items) => emit(BannersState(items: items)),
    );
  }
}
