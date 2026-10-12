import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/hotels_usecases.dart';
import 'hotels_state.dart';

class HotelsCubit extends Cubit<HotelsState> {
  HotelsCubit(this._list, this._get, this._book) : super(const HotelsState());

  final ListHotels _list;
  final GetHotels _get;
  final InquireHotels _book;

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

  Future<String?> book(String id, {required DateTime checkIn, required DateTime checkOut, int rooms = 1, int guests = 2}) async {
    final result = await _book(id, {
      'checkIn': checkIn.toUtc().toIso8601String(),
      'checkOut': checkOut.toUtc().toIso8601String(),
      'rooms': rooms,
      'guests': guests,
    });
    return result.fold((f) => f.message, (_) => null);
  }
}
