import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/events_item.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key, this.embedded = false});
  final bool embedded;

  Future<void> _create(BuildContext context) async {
    final created = await context.push<bool>('/customer/event/new');
    if (context.mounted && created == true) {
      context.read<EventsCubit>().load(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<EventsCubit>()..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.events, AppRefreshTopic.bookings, AppRefreshTopic.visits],
        onRefresh: (context) => context.read<EventsCubit>().load(silent: true),
        child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppTheme.canvas,
            body: Column(
              children: [
                ScreenHeader(
                  showBack: true,
                  eyebrow: l10n.myEvents,
                  title: l10n.eventsHeadline,
                  subtitle: l10n.eventsSubtitle,
                  trailing: FilledButton.icon(
                    onPressed: () => _create(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.createEvent),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<EventsCubit, EventsState>(
                    builder: (context, state) {
                      final upcoming = state.items
                          .where((item) => (eventDaysFromNow(item.raw['eventDate']) ?? 0) >= 0)
                          .toList();
                      final past = state.items
                          .where((item) => (eventDaysFromNow(item.raw['eventDate']) ?? 0) < 0)
                          .toList();
                      return AsyncBody(
                        loading: state.loading,
                        error: state.error,
                        empty: state.items.isEmpty,
                        emptyIcon: Icons.celebration_outlined,
                        emptyTitle: l10n.noEventsYet,
                        emptyMessage: l10n.noEventsHint,
                        emptyActionLabel: l10n.createEvent,
                        onEmptyAction: () => _create(context),
                        onRetry: () => context.read<EventsCubit>().load(),
                        child: RefreshIndicator(
                          color: AppTheme.navy,
                          onRefresh: () => context.read<EventsCubit>().load(silent: true),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            children: [
                              if (upcoming.isNotEmpty && past.isNotEmpty)
                                _SectionLabel(l10n.upcoming),
                              for (final item in upcoming) ...[
                                _EventCard(item: item),
                                const SizedBox(height: 12),
                              ],
                              if (past.isNotEmpty && upcoming.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _SectionLabel(l10n.pastEvents),
                              ],
                              for (final item in past) ...[
                                _EventCard(item: item, dimmed: true),
                                const SizedBox(height: 12),
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
        },
      ),
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
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: AppTheme.muted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.item, this.dimmed = false});

  final EventsItem item;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final date = parseApiDate(item.raw['eventDate']);
    final city = item.raw['city']?.toString() ?? '';
    final guests = item.raw['guestCount'];
    final category = item.raw['category'];
    final categoryName = category is Map ? localized(category['name'], locale) : '';
    final countdown = eventCountdownLabel(l10n, item.raw['eventDate']);
    final status = item.raw['status']?.toString() ?? 'planning';

    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () async {
            await context.push('/events/${item.id}');
            if (context.mounted) {
              context.read<EventsCubit>().load(silent: true);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.line),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateBadge(date: date),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localized(item.raw['title'], locale),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (categoryName.isNotEmpty) categoryName,
                            if (city.isNotEmpty) city,
                            if (guests != null) '$guests ${l10n.guests}',
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppTheme.muted, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            StatusBadge(label: status),
                            if (countdown.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.priceWash,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  countdown,
                                  style: const TextStyle(
                                    color: AppTheme.navy,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.navy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final day = date == null ? '—' : DateFormat('d', locale).format(date!);
    final month = date == null ? '' : DateFormat('MMM', locale).format(date!).toUpperCase();
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF003580), Color(0xFF0B5BB5)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            month,
            style: const TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
