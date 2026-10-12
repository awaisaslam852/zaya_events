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
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      channelName: json['channelName']?.toString(),
      callerId: json['callerId']?.toString(),
      calleeId: json['calleeId']?.toString(),
      raw: json,
    );
  }
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
