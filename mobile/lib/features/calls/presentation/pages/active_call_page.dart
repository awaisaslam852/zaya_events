import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/call_entity.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';

class ActiveCallPage extends StatefulWidget {
  const ActiveCallPage({super.key, required this.callId});
  final String callId;

  @override
  State<ActiveCallPage> createState() => _ActiveCallPageState();
}

class _ActiveCallPageState extends State<ActiveCallPage> {
  RtcEngine? _engine;
  String? _channel;
  int? _localUid;
  int? _remoteUid;
  bool _joining = false;
  bool _muted = false;
  bool _videoOff = false;
  bool _speaker = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = context.read<CallBloc>().state.token;
    if (token != null && _engine == null && !_joining) {
      _joining = true;
      _join(token);
    }
  }

  Future<void> _join(CallToken token) async {
    await [Permission.camera, Permission.microphone].request();
    final engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: token.appId));
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (!mounted) return;
          setState(() => _localUid = connection.localUid);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (!mounted) return;
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (!mounted) return;
          setState(() {
            if (_remoteUid == remoteUid) {
              _remoteUid = null;
            }
          });
        },
      ),
    );
    await engine.setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableVideo();
    await engine.enableAudio();
    await engine.startPreview();
    await engine.setEnableSpeakerphone(true);
    await engine.joinChannel(
      token: token.token,
      channelId: token.channel,
      uid: token.uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
    if (!mounted) {
      await engine.leaveChannel();
      await engine.release();
      return;
    }
    setState(() {
      _engine = engine;
      _channel = token.channel;
      _joining = false;
    });
  }

  Future<void> _hangUp() async {
    context.read<CallBloc>().add(CallEvent.end(widget.callId));
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      engine.leaveChannel();
      engine.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engine = _engine;
    return BlocListener<CallBloc, CallState>(
      listenWhen: (prev, next) => prev.token != next.token && next.token != null,
      listener: (context, state) {
        final token = state.token;
        if (token != null && _engine == null && !_joining) {
          _joining = true;
          _join(token);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(l10n.activeCall)),
        body: engine == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Positioned.fill(
                    child: _remoteUid == null
                        ? const ColoredBox(color: Colors.black)
                        : AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: engine,
                              canvas: VideoCanvas(uid: _remoteUid),
                              connection: RtcConnection(channelId: _channel),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    width: 120,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: engine,
                          canvas: VideoCanvas(uid: _localUid ?? 0),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.tonal(
                            onPressed: () async {
                              setState(() => _muted = !_muted);
                              await engine.muteLocalAudioStream(_muted);
                            },
                            child: Text(l10n.mute),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              setState(() => _videoOff = !_videoOff);
                              await engine.muteLocalVideoStream(_videoOff);
                            },
                            child: Text(l10n.camera),
                          ),
                          FilledButton.tonal(
                            onPressed: () => engine.switchCamera(),
                            child: Text(l10n.flip),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              setState(() => _speaker = !_speaker);
                              await engine.setEnableSpeakerphone(_speaker);
                            },
                            child: Text(l10n.speaker),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: _hangUp,
                            child: Text(l10n.endCall),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
