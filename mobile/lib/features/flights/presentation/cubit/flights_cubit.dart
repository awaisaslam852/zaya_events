import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/flights_usecases.dart';
import 'flights_state.dart';

class FlightsCubit extends Cubit<FlightsState> {
  FlightsCubit(this._list, this._get, this._book) : super(const FlightsState());

  final ListFlights _list;
  final GetFlights _get;
  final InquireFlights _book;

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

  Future<String?> book(String id, {int passengers = 1}) async {
    final result = await _book(id, {'passengers': passengers});
    return result.fold((f) => f.message, (_) => null);
  }
}
