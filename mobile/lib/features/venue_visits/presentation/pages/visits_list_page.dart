import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/session_role.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/visits_item.dart';
import '../../visit_copy.dart';
import '../cubit/visits_cubit.dart';
import '../cubit/visits_state.dart';

class VisitsListPage extends StatelessWidget {
  const VisitsListPage({super.key, this.embedded = false});
  final bool embedded;

  bool _isVendor(BuildContext context) => isVendorSession(context);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vendor = _isVendor(context);
    return BlocProvider(
      create: (_) => sl<VisitsCubit>()..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.visits],
        onRefresh: (context) => context.read<VisitsCubit>().load(silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(
              showBack: true,
              eyebrow: l10n.venueVisits,
              title: l10n.venueVisits,
              subtitle: vendor ? l10n.vendorVisitsSubtitle : l10n.visitsSubtitle,
            ),
            Expanded(
              child: BlocBuilder<VisitsCubit, VisitsState>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading,
                    error: state.error,
                    empty: state.items.isEmpty,
                    emptyIcon: Icons.meeting_room_outlined,
                    emptyTitle: l10n.noVisitsYet,
                    emptyMessage: vendor ? l10n.vendorNoVisitsHint : l10n.noVisitsHint,
                    emptyActionLabel: vendor ? null : l10n.browseToBook,
                    onEmptyAction: vendor ? null : () => context.push('/customer/venues'),
                    onRetry: () => context.read<VisitsCubit>().load(),
                    child: RefreshIndicator(
                      color: AppTheme.navy,
                      onRefresh: () => context.read<VisitsCubit>().load(silent: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        itemCount: state.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _VisitCard(item: state.items[index], isVendor: vendor),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.item, required this.isVendor});
  final VisitsItem item;
  final bool isVendor;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final venue = item.raw['venue'] is Map ? Map<String, dynamic>.from(item.raw['venue'] as Map) : <String, dynamic>{};
    final date = parseApiDate(item.raw['scheduledAt']);
    final image = catalogImageUrl(venue);
    final city = venue['city']?.toString() ?? item.raw['city']?.toString() ?? '';
    final l10n = AppLocalizations.of(context);
    final status = item.raw['status']?.toString() ?? '';
    final guest = visitGuestName(item.raw);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async {
          await context.push('/venue_visits/${item.id}');
          if (context.mounted) {
            context.read<VisitsCubit>().load(silent: true);
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
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: image == null
                        ? const ColoredBox(
                            color: AppTheme.wash,
                            child: Icon(Icons.apartment_outlined, color: AppTheme.navy),
                          )
                        : Image.network(image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localized(venue['name'] ?? item.raw['title'] ?? item.raw['name'], locale.languageCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (isVendor && guest.isNotEmpty) guest,
                          if (date != null) DateFormat.yMMMd(locale.toString()).add_jm().format(date),
                          if (city.isNotEmpty) city,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      StatusBadge(
                        label: visitStatusLabel(l10n, status),
                        code: status,
                      ),
                      if (isVendor && visitCanApprove(status)) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton(
                            onPressed: () async {
                              final ok = await showZayaConfirm(
                                context,
                                title: l10n.acceptVisitTitle,
                                message: l10n.acceptVisitMessage,
                                confirmLabel: l10n.acceptVisit,
                                icon: Icons.check_circle_outline,
                                tone: ZayaConfirmTone.primary,
                              );
                              if (!ok || !context.mounted) {
                                return;
                              }
                              final error = await context.read<VisitsCubit>().approve(item.id);
                              if (!context.mounted) {
                                return;
                              }
                              showZayaSnack(
                                context,
                                error ?? l10n.visitAccepted,
                                kind: error == null ? ZayaSnackKind.success : ZayaSnackKind.error,
                              );
                            },
                            child: Text(l10n.acceptVisit),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.navy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
