import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventsListPage extends StatelessWidget {
  const EventsListPage({super.key, this.embedded = false});
  final bool embedded;

  Future<void> _create(BuildContext context) async {
    final created = await context.push<bool>('/customer/event/new');
    if (context.mounted && created == true) {
      context.read<EventsCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<EventsCubit>()..load(),
      child: Builder(
        builder: (context) {
          return Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            if (!embedded)
              ScreenHeader(
                eyebrow: l10n.myEvents,
                title: 'Your celebrations',
                subtitle: 'Create an event, then enquire and book vendors.',
                trailing: FilledButton.icon(
                  onPressed: () => _create(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.createEvent),
                ),
              ),
            Expanded(
              child: BlocBuilder<EventsCubit, EventsState>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading,
                    error: state.error,
                    empty: state.items.isEmpty,
                    emptyIcon: Icons.celebration_outlined,
                    emptyTitle: 'No events yet',
                    emptyMessage: 'Tap New event, choose a type (wedding, birthday…), add a date, and save.',
                    emptyActionLabel: l10n.createEvent,
                    onEmptyAction: () => _create(context),
                    onRetry: () => context.read<EventsCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        final locale = Localizations.localeOf(context).languageCode;
                        final date = item.raw['eventDate']?.toString().split('T').first ?? '';
                        return Card(
                          child: InkWell(
                            onTap: () => context.push('/events/${item.id}'),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCEBFA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.celebration, color: AppTheme.navy),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localized(item.raw['title'], locale),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          [date, item.raw['city']].where((e) => e != null && e.toString().isNotEmpty).join(' · '),
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(label: item.raw['status']?.toString() ?? 'planning'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
    );
  }
}
