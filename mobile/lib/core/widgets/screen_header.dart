import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showBack = false,
    this.compact = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showBack;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final showEyebrow = !compact && eyebrow.isNotEmpty;
    final showSubtitle = !compact && subtitle != null && subtitle!.isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00183D), Color(0xFF003580), Color(0xFF0B5BB5)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        showBack ? 4 : 16,
        MediaQuery.paddingOf(context).top + (compact ? 2 : 6),
        12,
        compact ? 10 : 22,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showEyebrow) ...[
                  Text(
                    eyebrow.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.yellow,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 20 : 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (showSubtitle) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: const TextStyle(color: Colors.white70, height: 1.35)),
                ],
              ],
            ),
          ),
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(top: compact || showBack ? 0 : 8),
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.navy : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppTheme.navy : AppTheme.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: selected ? Colors.white : AppTheme.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.code});

  final String label;
  final String? code;

  @override
  Widget build(BuildContext context) {
    final tone = switch ((code ?? label).toUpperCase()) {
      'CONFIRMED' || 'PAID' || 'APPROVED' || 'PUBLISHED' || 'COMPLETED' => const Color(0xFF0F766E),
      'REQUESTED' || 'PENDING' || 'INQUIRY' || 'UNDER_REVIEW' || 'PLANNING' || 'RESCHEDULED' => const Color(0xFFB45309),
      'REJECTED' || 'CANCELLED' || 'NO_SHOW' => const Color(0xFFB91C1C),
      _ => AppTheme.navy,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: tone.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: tone, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class EmptyHero extends StatelessWidget {
  const EmptyHero({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFDCEBFA),
              child: Icon(icon, size: 34, color: AppTheme.navy),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.add), label: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.wash,
                child: Icon(icon, color: AppTheme.navy),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, maxLines: 2, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
