import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_event.freezed.dart';

@freezed
abstract class CallEvent with _$CallEvent {
  const factory CallEvent.started() = _Started;
  const factory CallEvent.incomingFromPush(Map<String, dynamic> payload) = _IncomingFromPush;
  const factory CallEvent.outgoing({required String calleeId, String? bookingId}) = _Outgoing;
  const factory CallEvent.accept(String id) = _Accept;
  const factory CallEvent.reject(String id) = _Reject;
  const factory CallEvent.end(String id) = _End;
  const factory CallEvent.loadHistory() = _LoadHistory;
}
