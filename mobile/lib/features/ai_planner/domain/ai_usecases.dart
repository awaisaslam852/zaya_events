import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/api_client.dart';

class AiPlannerRepository {
  AiPlannerRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Map<String, dynamic>>> chat(List<Map<String, String>> messages, {String? eventId}) {
    return _client.post(
      '/ai/chat',
      data: {'messages': messages, if (eventId != null) 'eventId': eventId, 'locale': 'en'},
      parse: (d) => Map<String, dynamic>.from(d as Map),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> checklist(String eventId) {
    return _client.post('/ai/checklist', data: {'eventId': eventId}, parse: (d) => Map<String, dynamic>.from(d as Map));
  }

  Future<Either<Failure, Map<String, dynamic>>> recommendations(String eventId) {
    return _client.post(
      '/ai/recommendations',
      data: {'eventId': eventId},
      parse: (d) => Map<String, dynamic>.from(d as Map),
    );
  }
}

class AiChat {
  AiChat(this._repo);
  final AiPlannerRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(List<Map<String, String>> messages, {String? eventId}) =>
      _repo.chat(messages, eventId: eventId);
}
