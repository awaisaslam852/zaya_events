import 'package:zaya_events/core/bloc/safe_cubit.dart';
import '../../domain/usecases/venues_usecases.dart';
import 'venues_state.dart';

class VenuesCubit extends SafeCubit<VenuesState> {
  VenuesCubit(this._list, this._get) : super(const VenuesState());

  final ListVenues _list;
  final GetVenues _get;

  Future<void> load({Map<String, dynamic>? query}) async {
    emit(state.copyWith(loading: true, error: null));
    final result = await _list(query: query);
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
}
