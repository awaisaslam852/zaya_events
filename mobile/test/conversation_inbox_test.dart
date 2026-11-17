import 'package:flutter_test/flutter_test.dart';
import 'package:zaya_events/features/chat/conversation_inbox.dart';

void main() {
  test('keeps one inbox row per person and prefers the thread with a message', () {
    const me = 'user-a';
    final empty = {
      'id': 'empty',
      'lastMessageAt': null,
      'participantA': {'id': me, 'firstName': 'Me'},
      'participantB': {'id': 'insha', 'firstName': 'insha', 'lastName': 'Awais'},
    };
    final dated = {
      'id': 'dated',
      'lastMessageAt': '2026-11-15T10:00:00.000Z',
      'participantA': {'id': me, 'firstName': 'Me'},
      'participantB': {'id': 'insha', 'firstName': 'insha', 'lastName': 'Awais'},
    };
    final support = {
      'id': 'support',
      'lastMessageAt': '2026-11-14T10:00:00.000Z',
      'participantA': {'id': me, 'firstName': 'Me'},
      'participantB': {'id': 'admin', 'firstName': 'Zaya', 'lastName': 'Support'},
    };

    final rows = uniqueConversationsByPeer([empty, dated, support], me);
    expect(rows.map((row) => row['id']), ['dated', 'support']);
  });

  test('reads the peer avatar key so chat can show a profile photo', () {
    const me = 'user-a';
    final item = {
      'id': 'c1',
      'participantA': {'id': me, 'firstName': 'Me'},
      'participantB': {
        'id': 'insha',
        'firstName': 'insha',
        'lastName': 'Awais',
        'avatarKey': 'avatars/insha.jpg',
        'vendor': {'logoKey': 'uploads/logo.png'},
      },
    };
    expect(conversationPeerName(item, me), 'insha Awais');
    expect(conversationPeerInitials(item, me), 'IA');
    expect(conversationPeerImageKey(item, me), 'avatars/insha.jpg');
    expect(
      conversationPeerImageKey({
        'participantA': {'id': me},
        'participantB': {
          'id': 'vendor-1',
          'vendor': {'logoKey': 'uploads/logo.png'},
        },
      }, me),
      'uploads/logo.png',
    );
  });
}
