import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../call_audio.dart';
import '../../domain/entities/call_entity.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';
import '../widgets/call_stage.dart';

class ActiveCallPage extends StatefulWidget {
  const ActiveCallPage({super.key, required this.callId});
  final String callId;

  @override
  State<ActiveCallPage> createState() => _ActiveCallPageState();
}

class _ActiveCallPageState extends State<ActiveCallPage> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _joining = false;
  bool _muted = false;
  bool _speaker = true;
  bool _micDenied = false;
  String? _joinError;
  DateTime? _connectedAt;
  Timer? _ticker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = context.read<CallBloc>().state.token;
    if (token != null && _engine == null && !_joining && !_micDenied) {
      _joining = true;
      _join(token);
    }
  }

  Future<void> _join(CallToken token) async {
    final permission = await ensureCallAudioPermission();
    if (permission != CallAudioPermission.granted) {
      if (mounted) {
        setState(() {
          _micDenied = true;
          _joining = false;
        });
      }
      return;
    }
    try {
      final engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(appId: token.appId));
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            if (!mounted) return;
            setState(() => _connectedAt ??= DateTime.now());
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (!mounted) return;
            setState(() {
              _remoteUid = remoteUid;
              _connectedAt ??= DateTime.now();
            });
            _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
              if (mounted) setState(() {});
            });
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
      await engine.enableAudio();
      await engine.disableVideo();
      await engine.muteLocalAudioStream(false);
      await engine.setDefaultAudioRouteToSpeakerphone(true);
      await engine.setEnableSpeakerphone(true);
      await engine.joinChannel(
        token: token.token,
        channelId: token.channel,
        uid: token.uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: false,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: false,
        ),
      );
      if (!mounted) {
        await engine.leaveChannel();
        await engine.release();
        return;
      }
      setState(() {
        _engine = engine;
        _joining = false;
        _joinError = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _joining = false;
          _joinError = error.toString();
        });
      }
    }
  }

  Future<void> _hangUp() async {
    _ticker?.cancel();
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
    _ticker?.cancel();
    final engine = _engine;
    _engine = null;
    if (engine != null) {
      engine.leaveChannel();
      engine.release();
    }
    super.dispose();
  }

  String _elapsed(AppLocalizations l10n) {
    final started = _connectedAt;
    if (started == null) {
      return l10n.connectingCall;
    }
    final seconds = DateTime.now().difference(started).inSeconds;
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engine = _engine;
    return BlocConsumer<CallBloc, CallState>(
      listenWhen: (prev, next) =>
          (prev.token != next.token && next.token != null) ||
          (prev.active != null && next.active == null),
      listener: (context, state) {
        final token = state.token;
        if (token != null && _engine == null && !_joining && !_micDenied) {
          _joining = true;
          _join(token);
        }
        if (state.active == null && mounted) {
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        final call = state.active;
        final name = call?.peerLabel(incoming: false, fallback: l10n.activeCall) ?? l10n.activeCall;
        final connected = _remoteUid != null;
        return CallStage(
          name: name,
          initials: callInitials(name),
          status: _micDenied
              ? l10n.micPermissionTitle
              : (_joinError ?? (engine == null ? l10n.connectingCall : (connected ? _elapsed(l10n) : l10n.ringingCall))),
          pulsing: engine == null && !_micDenied,
          permissionDenied: _micDenied,
          showAudioControls: engine != null && !_micDenied,
          muted: _muted,
          speakerOn: _speaker,
          onEnd: _hangUp,
          onMute: engine == null
              ? null
              : () async {
                  setState(() => _muted = !_muted);
                  await engine.muteLocalAudioStream(_muted);
                },
          onSpeaker: engine == null
              ? null
              : () async {
                  setState(() => _speaker = !_speaker);
                  await engine.setEnableSpeakerphone(_speaker);
                },
          onOpenSettings: openAppSettings,
          onRetry: () {
            final token = context.read<CallBloc>().state.token;
            if (token == null) {
              return;
            }
            setState(() {
              _micDenied = false;
              _joining = true;
            });
            _join(token);
          },
        );
      },
    );
  }
}
