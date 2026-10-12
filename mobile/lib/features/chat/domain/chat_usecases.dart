import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/pagination/paginated.dart';

class ChatRepository {
  ChatRepository(this._client);
  final ApiClient _client;

  Future<Either<Failure, Paginated<Map<String, dynamic>>>> conversations({int page = 1}) {
    return _client.get('/chat/conversations', query: {'page': page}, parse: _page);
  }

  Future<Either<Failure, Paginated<Map<String, dynamic>>>> messages(String id, {int page = 1}) {
    return _client.get('/chat/conversations/$id/messages', query: {'page': page}, parse: _page);
  }

  Future<Either<Failure, Map<String, dynamic>>> send(String id, String body) {
    return _client.post(
      '/chat/conversations/$id/messages',
      data: {'type': 'TEXT', 'body': body},
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> getConversation(String id) {
    return _client.get(
      '/chat/conversations/$id',
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> start(String participantId) {
    return _client.post(
      '/chat/conversations',
      data: {'participantId': participantId},
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> startSupport() {
    return _client.post(
      '/chat/conversations/support',
      data: {},
      parse: (data) => Map<String, dynamic>.from(data as Map),
    );
  }

  Paginated<Map<String, dynamic>> _page(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final items = (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return Paginated(
      items: items,
      total: (map['total'] as num?)?.toInt() ?? items.length,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
    );
  }
}

class ListConversations {
  ListConversations(this._repo);
  final ChatRepository _repo;
  Future<Either<Failure, Paginated<Map<String, dynamic>>>> call() => _repo.conversations();
}

class ListMessages {
  ListMessages(this._repo);
  final ChatRepository _repo;
  Future<Either<Failure, Paginated<Map<String, dynamic>>>> call(String id) => _repo.messages(id);
}

class SendMessage {
  SendMessage(this._repo);
  final ChatRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(String id, String body) => _repo.send(id, body);
}

class GetConversation {
  GetConversation(this._repo);
  final ChatRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(String id) => _repo.getConversation(id);
}

class StartConversation {
  StartConversation(this._repo);
  final ChatRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call(String participantId) => _repo.start(participantId);
}

class StartSupport {
  StartSupport(this._repo);
  final ChatRepository _repo;
  Future<Either<Failure, Map<String, dynamic>>> call() => _repo.startSupport();
}
