Map<String, dynamic>? conversationPeerMap(Map<String, dynamic> item, String myId) {
  final a = item['participantA'];
  final b = item['participantB'];
  final aMap = a is Map ? Map<String, dynamic>.from(a) : null;
  final bMap = b is Map ? Map<String, dynamic>.from(b) : null;
  if (aMap?['id']?.toString() == myId) {
    return bMap;
  }
  if (bMap?['id']?.toString() == myId) {
    return aMap;
  }
  return bMap ?? aMap;
}

String conversationPeerId(Map<String, dynamic> item, String myId) {
  final peer = conversationPeerMap(item, myId);
  if (peer != null) {
    return peer['id']?.toString() ?? '';
  }
  final aId = item['participantAId']?.toString() ?? '';
  final bId = item['participantBId']?.toString() ?? '';
  if (aId == myId) {
    return bId;
  }
  if (bId == myId) {
    return aId;
  }
  return bId.isNotEmpty ? bId : aId;
}

String conversationPeerName(Map<String, dynamic> item, String myId) {
  final peer = conversationPeerMap(item, myId);
  if (peer == null) {
    return '';
  }
  final person = [
    peer['displayName'],
    '${peer['firstName'] ?? ''} ${peer['lastName'] ?? ''}'.trim(),
  ].map((value) => value?.toString().trim() ?? '').firstWhere((value) => value.isNotEmpty, orElse: () => '');
  if (person.isNotEmpty) {
    return person;
  }
  final vendor = peer['vendor'];
  if (vendor is Map) {
    final business = vendor['businessName'];
    if (business is Map) {
      final named = (business['en'] ?? business['ar'])?.toString().trim() ?? '';
      if (named.isNotEmpty) {
        return named;
      }
    } else if (business != null && business.toString().trim().isNotEmpty) {
      return business.toString().trim();
    }
  }
  return '';
}

String conversationPeerInitials(Map<String, dynamic> item, String myId) {
  final name = conversationPeerName(item, myId);
  if (name.isEmpty) {
    return '?';
  }
  final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  return parts.take(2).map((part) => part[0]).join().toUpperCase();
}

String? conversationPeerImageKey(Map<String, dynamic> item, String myId) {
  final peer = conversationPeerMap(item, myId);
  if (peer == null) {
    return null;
  }
  final vendor = peer['vendor'];
  final candidates = <dynamic>[
    peer['avatarKey'],
    peer['avatarUrl'],
    if (vendor is Map) vendor['logoKey'],
    if (vendor is Map) vendor['coverKey'],
    if (vendor is Map) vendor['logoUrl'],
  ];
  for (final value in candidates) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) {
      return text;
    }
  }
  return null;
}

bool conversationHasActivity(Map<String, dynamic> item) {
  return (item['lastMessageAt']?.toString() ?? '').isNotEmpty;
}

/// One inbox row per person. Prefer the thread that already has a message.
List<Map<String, dynamic>> uniqueConversationsByPeer(
  List<Map<String, dynamic>> items,
  String myId,
) {
  final kept = <String, Map<String, dynamic>>{};
  final order = <String>[];
  for (final item in items) {
    final peerId = conversationPeerId(item, myId);
    final key = peerId.isEmpty ? item['id']?.toString() ?? '' : peerId;
    if (key.isEmpty) {
      continue;
    }
    final current = kept[key];
    if (current == null) {
      kept[key] = item;
      order.add(key);
      continue;
    }
    if (conversationHasActivity(item) && !conversationHasActivity(current)) {
      kept[key] = item;
    }
  }
  return [for (final key in order) kept[key]!];
}
