import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notifications_item.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsListPage extends StatelessWidget {
  const NotificationsListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.notifications, AppRefreshTopic.bookings, AppRefreshTopic.visits],
        onRefresh: (context) => context.read<NotificationsCubit>().load(silent: true),
        child: const _NotificationsView(),
      ),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  bool _unreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(
            showBack: true,
            eyebrow: l10n.notifications,
            title: l10n.notificationsHeadline,
            subtitle: l10n.notificationsSubtitle,
            trailing: TextButton(
              onPressed: () => context.read<NotificationsCubit>().markAllRead(),
              child: Text(
                l10n.markAllRead,
                style: const TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                FilterPill(
                  label: l10n.allFilter,
                  selected: !_unreadOnly,
                  onTap: () => setState(() => _unreadOnly = false),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: l10n.unread,
                  selected: _unreadOnly,
                  onTap: () => setState(() => _unreadOnly = true),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                final filtered = _unreadOnly
                    ? state.items.where((item) => notificationUnread(item.raw)).toList()
                    : state.items;
                final now = DateTime.now();
                final today = filtered.where((item) {
                  final date = parseApiDate(item.raw['createdAt'] ?? item.raw['sentAt']);
                  return date != null && isSameCalendarDay(date, now);
                }).toList();
                final earlier = filtered.where((item) => !today.contains(item)).toList();
                return AsyncBody(
                  loading: state.loading,
                  error: state.error,
                  empty: filtered.isEmpty,
                  emptyIcon: Icons.notifications_none_rounded,
                  emptyTitle: l10n.noNotificationsYet,
                  emptyMessage: l10n.noNotificationsHint,
                  onRetry: () => context.read<NotificationsCubit>().load(),
                  child: RefreshIndicator(
                    color: AppTheme.navy,
                    onRefresh: () => context.read<NotificationsCubit>().load(silent: true),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        if (today.isNotEmpty) _SectionLabel(l10n.today),
                        for (final item in today) ...[
                          _NotificationCard(item: item),
                          const SizedBox(height: 10),
                        ],
                        if (earlier.isNotEmpty) ...[
                          if (today.isNotEmpty) const SizedBox(height: 8),
                          _SectionLabel(l10n.earlier),
                        ],
                        for (final item in earlier) ...[
                          _NotificationCard(item: item),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.muted, letterSpacing: 0.4),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});
  final NotificationsItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final unread = notificationUnread(item.raw);
    final title = localized(item.raw['title'] ?? item.raw['name'], locale);
    final body = localized(item.raw['body'], locale);
    final time = relativeTimeLabel(l10n, item.raw['createdAt'] ?? item.raw['sentAt']);
    final destination = notificationDestination(item.raw);

    return Material(
      color: unread ? const Color(0xFFFFF8E6) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          context.read<NotificationsCubit>().markRead(item.id);
          if (destination != null) {
            context.push(destination);
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: unread ? const Color(0xFFF3D27A) : AppTheme.line),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: unread ? AppTheme.yellow : AppTheme.wash,
                  child: Icon(notificationTypeIcon(item.raw), color: AppTheme.navy, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(color: AppTheme.navy, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.muted, height: 1.35, fontSize: 13),
                        ),
                      ],
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
