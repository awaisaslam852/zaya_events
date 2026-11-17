import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class CallStage extends StatefulWidget {
  const CallStage({
    super.key,
    required this.name,
    required this.status,
    required this.initials,
    this.subtitle,
    this.pulsing = false,
    this.permissionDenied = false,
    this.muted = false,
    this.speakerOn = true,
    this.showAccept = false,
    this.showAudioControls = false,
    this.onBack,
    this.onEnd,
    this.onAccept,
    this.onReject,
    this.onMute,
    this.onSpeaker,
    this.onOpenSettings,
    this.onRetry,
    this.showBack = true,
  });

  final String name;
  final String status;
  final String initials;
  final String? subtitle;
  final bool pulsing;
  final bool permissionDenied;
  final bool muted;
  final bool speakerOn;
  final bool showAccept;
  final bool showAudioControls;
  final VoidCallback? onBack;
  final VoidCallback? onEnd;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMute;
  final VoidCallback? onSpeaker;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onRetry;
  final bool showBack;

  @override
  State<CallStage> createState() => _CallStageState();
}

class _CallStageState extends State<CallStage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF001B40),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00285C), Color(0xFF001326)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                Row(
                  children: [
                    if (widget.showBack)
                      IconButton(
                        onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                      )
                    else
                      const SizedBox(width: 48),
                    const Spacer(),
                    Text(
                      l10n.voiceCall,
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final scale = widget.pulsing ? 1 + (_pulse.value * 0.08) : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.blue, AppTheme.navy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: AppTheme.yellow.withValues(alpha: 0.85), width: 3),
                      boxShadow: [
                        BoxShadow(color: AppTheme.yellow.withValues(alpha: 0.28), blurRadius: 24, spreadRadius: 2),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.initials,
                      style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.status,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle ?? l10n.encryptedCall,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                ),
                const Spacer(flex: 3),
                if (widget.permissionDenied) ...[
                  Text(
                    l10n.micPermissionTitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.micPermissionBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onOpenSettings,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                          ),
                          child: Text(l10n.openSettings),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.onRetry,
                          child: Text(l10n.tryAgain),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                if (widget.showAudioControls)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundControl(
                        icon: widget.muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        label: widget.muted ? l10n.unmute : l10n.mute,
                        active: widget.muted,
                        onTap: widget.onMute,
                      ),
                      _RoundControl(
                        icon: widget.speakerOn ? Icons.volume_up_rounded : Icons.hearing_rounded,
                        label: widget.speakerOn ? l10n.speaker : l10n.earpiece,
                        active: widget.speakerOn,
                        onTap: widget.onSpeaker,
                      ),
                    ],
                  ),
                if (widget.showAudioControls) const SizedBox(height: 28),
                if (widget.showAccept)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        color: const Color(0xFFE11D48),
                        icon: Icons.call_end_rounded,
                        label: l10n.reject,
                        onTap: widget.onReject,
                      ),
                      _ActionButton(
                        color: const Color(0xFF16A34A),
                        icon: Icons.call_rounded,
                        label: l10n.accept,
                        onTap: widget.onAccept,
                      ),
                    ],
                  )
                else
                  _ActionButton(
                    color: const Color(0xFFE11D48),
                    icon: Icons.call_end_rounded,
                    label: l10n.endCall,
                    onTap: widget.onEnd,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.label, required this.onTap, this.active = false});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.14),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(icon, color: active ? AppTheme.navy : Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.color, required this.icon, required this.label, required this.onTap});

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.45),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 76,
              height: 76,
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
