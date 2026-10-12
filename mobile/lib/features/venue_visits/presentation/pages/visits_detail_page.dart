import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/visits_cubit.dart';
import '../cubit/visits_state.dart';

class VisitsDetailPage extends StatelessWidget {
  const VisitsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _run(BuildContext context, Future<String?> Function() action) async {
    final error = await action();
    if (!context.mounted) {
      return;
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VisitsCubit>()..loadOne(id),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.venueVisits)),
        body: BlocBuilder<VisitsCubit, VisitsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<VisitsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : Builder(
                      builder: (context) {
                        final raw = item.raw;
                        final locale = Localizations.localeOf(context).languageCode;
                        final venue = raw['venue'] is Map ? Map<String, dynamic>.from(raw['venue'] as Map) : <String, dynamic>{};
                        final status = raw['status']?.toString() ?? '';
                        final terminal = const {'CANCELLED', 'DECIDED'}.contains(status);
                        final canDecide = const {'CONFIRMED', 'COMPLETED', 'APPROVED', 'RESCHEDULED'}.contains(status);
                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            JsonTitle(
                              venue['name'] ?? raw['title'],
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            StatusBadge(label: status),
                            const SizedBox(height: 12),
                            Text(raw['scheduledAt']?.toString().replaceFirst('T', ' ').split('.').first ?? ''),
                            if (localized(raw['notes'], locale).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(localized(raw['notes'], locale)),
                            ],
                            if (raw['decision'] is Map) ...[
                              const SizedBox(height: 12),
                              Text(
                                (raw['decision'] as Map)['accepted'] == true ? l10n.willBook : l10n.wontBook,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (canDecide) ...[
                              ZayaPrimaryButton(
                                label: l10n.willBook,
                                icon: Icons.thumb_up_alt_outlined,
                                onPressed: () => _run(context, () => context.read<VisitsCubit>().decide(id, accepted: true)),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => _run(context, () => context.read<VisitsCubit>().decide(id, accepted: false)),
                                icon: const Icon(Icons.thumb_down_alt_outlined),
                                label: Text(l10n.wontBook),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (!terminal)
                              TextButton(
                                onPressed: () => _run(context, () => context.read<VisitsCubit>().cancel(id)),
                                child: Text(l10n.cancelVisit, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                              ),
                          ],
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
