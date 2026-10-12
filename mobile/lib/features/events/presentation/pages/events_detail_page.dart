import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventsDetailPage extends StatelessWidget {
  const EventsDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<EventsCubit>()..loadOne(id),
      child: Builder(
        builder: (context) {
          return Scaffold(
        backgroundColor: AppTheme.canvas,
        appBar: AppBar(
          title: Text(l10n.eventHub),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final updated = await context.push<bool>('/events/$id/edit');
                if (context.mounted && updated == true) {
                  context.read<EventsCubit>().loadOne(id);
                }
              },
            ),
          ],
        ),
        body: BlocBuilder<EventsCubit, EventsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<EventsCubit>().loadOne(id),
              child: item == null ? const SizedBox.shrink() : _Hub(raw: item.raw, eventId: id),
            );
          },
        ),
      );
        },
      ),
    );
  }
}

class _Hub extends StatelessWidget {
  const _Hub({required this.raw, required this.eventId});
  final Map<String, dynamic> raw;
  final String eventId;

  String _money(dynamic value, String currency) {
    final amount = num.tryParse('$value') ?? 0;
    return '$currency ${amount.toStringAsFixed(0)}';
  }

  String _day(dynamic value) => value?.toString().split('T').first ?? '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cost = raw['cost'] is Map ? Map<String, dynamic>.from(raw['cost'] as Map) : <String, dynamic>{};
    final currency = cost['currency']?.toString() ?? raw['currency']?.toString() ?? 'AED';
    final bookings = (raw['bookings'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final visits = (raw['visits'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final checklist = (raw['checklist'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    final travel = bookings.where((b) => ['FLIGHT', 'HOTEL'].contains(b['type']?.toString())).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        JsonTitle(raw['title'], style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadge(label: raw['status']?.toString() ?? 'planning'),
            if (raw['city'] != null) Chip(label: Text('${raw['city']}')),
            if (raw['preferredVenueType'] != null) Chip(label: Text('${raw['preferredVenueType']}')),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          [_day(raw['eventDate']), if (raw['endDate'] != null) _day(raw['endDate']), '${raw['guestCount'] ?? 0} ${l10n.guests}']
              .where((e) => e.toString().isNotEmpty)
              .join(' · '),
          style: TextStyle(color: Colors.grey.shade700),
        ),
        if (localized(raw['notes'], locale).isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(localized(raw['notes'], locale)),
        ],
        const SizedBox(height: 16),
        Text(l10n.costOverview, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _Stat(label: l10n.bookings, value: _money(cost['bookingsTotal'], currency))),
            const SizedBox(width: 8),
            Expanded(child: _Stat(label: l10n.paid, value: _money(cost['paid'], currency))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _Stat(label: l10n.remaining, value: _money(cost['remaining'], currency))),
            const SizedBox(width: 8),
            Expanded(
              child: _Stat(
                label: l10n.budget,
                value: cost['budgetMax'] == null && cost['budgetMin'] == null
                    ? '—'
                    : '${_money(cost['budgetMin'] ?? 0, currency)}–${_money(cost['budgetMax'] ?? cost['budgetMin'], currency)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          title: l10n.checklist,
          empty: checklist.isEmpty,
          children: [
            for (final item in checklist)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: item['done'] == true,
                title: Text(localized(item['title'], locale)),
                onChanged: (value) {
                  final next = checklist
                      .map(
                        (row) => {
                          ...row,
                          'done': row['id']?.toString() == item['id']?.toString() ? value == true : row['done'] == true,
                        },
                      )
                      .toList();
                  context.read<EventsCubit>().update(eventId, {'checklist': next});
                },
              ),
          ],
        ),
        _Section(
          title: l10n.bookings,
          empty: bookings.isEmpty,
          children: [
            for (final booking in bookings)
              Card(
                child: ListTile(
                  onTap: () => context.push('/bookings/${booking['id']}'),
                  title: Text(
                    localized(
                      booking['venue'] is Map
                          ? (booking['venue'] as Map)['name']
                          : booking['listing'] is Map
                              ? (booking['listing'] as Map)['title']
                              : booking['bookingNumber'] ?? booking['type'],
                      locale,
                    ),
                  ),
                  subtitle: Text('${booking['type']} · ${booking['status']}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
          ],
        ),
        _Section(
          title: l10n.venueVisits,
          empty: visits.isEmpty,
          children: [
            for (final visit in visits)
              Card(
                child: ListTile(
                  onTap: () => context.push('/venue_visits/${visit['id']}'),
                  title: Text(localized(visit['venue'] is Map ? (visit['venue'] as Map)['name'] : l10n.venueVisits, locale)),
                  subtitle: Text('${_day(visit['scheduledAt'])} · ${visit['status']}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
          ],
        ),
        _Section(
          title: l10n.travel,
          empty: travel.isEmpty,
          children: [
            for (final trip in travel)
              Card(
                child: ListTile(
                  leading: Icon(trip['type'] == 'FLIGHT' ? Icons.flight_takeoff : Icons.hotel_outlined),
                  title: Text(trip['bookingNumber']?.toString() ?? trip['type']?.toString() ?? ''),
                  subtitle: Text('${trip['type']} · ${trip['status']}'),
                  onTap: () => context.push('/bookings/${trip['id']}'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ZayaSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.navy)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, required this.empty});
  final String title;
  final List<Widget> children;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          if (empty) Text(AppLocalizations.of(context).empty, style: TextStyle(color: Colors.grey.shade600)) else ...children,
        ],
      ),
    );
  }
}
