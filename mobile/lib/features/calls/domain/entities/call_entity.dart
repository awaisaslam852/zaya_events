class CallEntity {
  const CallEntity({
    required this.id,
    required this.status,
    this.channelName,
    this.callerId,
    this.calleeId,
    this.raw = const {},
  });

  final String id;
  final String status;
  final String? channelName;
  final String? callerId;
  final String? calleeId;
  final Map<String, dynamic> raw;

  factory CallEntity.fromJson(Map<String, dynamic> json) {
    return CallEntity(
      id: json['id']?.toString() ?? json['callId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      channelName: json['channelName']?.toString(),
      callerId: json['callerId']?.toString(),
      calleeId: json['calleeId']?.toString(),
      raw: json,
    );
  }

  factory CallEntity.fromIncoming(Map<String, dynamic> json) {
    return CallEntity(
      id: json['callId']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'RINGING',
      channelName: json['channelName']?.toString(),
      callerId: json['callerId']?.toString(),
      calleeId: json['calleeId']?.toString(),
      raw: json,
    );
  }

  String peerLabel({required bool incoming, String fallback = 'Zaya Events'}) {
    if (incoming) {
      return _nameFrom(raw['callerName']) ?? _personName(raw['caller']) ?? fallback;
    }
    return _nameFrom(raw['calleeName']) ?? _personName(raw['callee']) ?? fallback;
  }

  String initials({required bool incoming}) => callInitials(peerLabel(incoming: incoming));
}

String callInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return 'Z';
  }
  return parts.take(2).map((part) => part[0]).join().toUpperCase();
}

String? _nameFrom(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

String? _personName(dynamic row) {
  if (row is! Map) {
    return null;
  }
  final map = Map<String, dynamic>.from(row);
  final text = [map['firstName'], map['lastName'], map['businessName']]
      .map((value) => value?.toString().trim() ?? '')
      .where((value) => value.isNotEmpty)
      .join(' ');
  return text.isEmpty ? null : text;
}

class CallToken {
  const CallToken({required this.token, required this.appId, required this.channel, required this.uid});
  final String token;
  final String appId;
  final String channel;
  final int uid;

  factory CallToken.fromJson(Map<String, dynamic> json) {
    return CallToken(
      token: json['token']?.toString() ?? '',
      appId: json['appId']?.toString() ?? '',
      channel: json['channel']?.toString() ?? json['channelName']?.toString() ?? '',
      uid: (json['uid'] as num?)?.toInt() ?? 0,
    );
  }
}
