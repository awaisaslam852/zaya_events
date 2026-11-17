import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/booking_requests_usecases.dart';

class BookingRequestsCubit extends SafeCubit<({bool loading, String? error, List<Map<String, dynamic>> items})> {
  BookingRequestsCubit(this._list, this._transition) : super((loading: false, error: null, items: const []));

  final ListBookingRequests _list;
  final TransitionBooking _transition;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit((loading: true, error: null, items: state.items));
    }
    final result = await _list();
    result.fold(
      (f) => emit((loading: false, error: f.message, items: state.items)),
      (page) => emit((
        loading: false,
        error: null,
        items: page.items.where((item) => bookingNeedsVendorDecision(item['status']?.toString())).toList(),
      )),
    );
  }

  Future<String?> act(String id, String action) async {
    final result = await _transition(id, action);
    final error = result.fold((f) => f.message, (_) => null);
    if (error != null) {
      return error;
    }
    AppRefresh.instance.afterBooking();
    await load(silent: true);
    return null;
  }
}

class BookingRequestsPage extends StatelessWidget {
  const BookingRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => BookingRequestsCubit(sl(), sl())..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.bookings],
        onRefresh: (context) => context.read<BookingRequestsCubit>().load(silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(
              eyebrow: l10n.requests,
              title: l10n.bookingInbox,
              subtitle: l10n.bookingInboxSubtitle,
            ),
            Expanded(
              child: BlocBuilder<BookingRequestsCubit, ({bool loading, String? error, List<Map<String, dynamic>> items})>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading,
                    error: state.error,
                    empty: state.items.isEmpty,
                    emptyIcon: Icons.inbox_outlined,
                    emptyTitle: l10n.noPendingRequests,
                    emptyMessage: l10n.noPendingRequestsHint,
                    emptyActionLabel: l10n.bookingHistory,
                    onEmptyAction: () => context.push('/vendor/bookings'),
                    onRetry: () => context.read<BookingRequestsCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _RequestCard(item: state.items[index]),
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

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final status = item['status']?.toString() ?? '';
    final pending = bookingNeedsVendorDecision(status);
    final title = localized(bookingTitleRaw(item), locale);
    final number = item['bookingNumber']?.toString() ?? item['id']?.toString() ?? '';
    final currency = item['currency']?.toString() ?? 'AED';
    final amount = formatMoney(item['totalAmount'], currency);
    final id = item['id']?.toString() ?? '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: id.isEmpty
            ? null
            : () async {
                await context.push('/bookings/$id');
                if (context.mounted) {
                  context.read<BookingRequestsCubit>().load(silent: true);
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.wash,
                      child: Icon(bookingTypeIcon(item['type']?.toString()), color: AppTheme.navy),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isEmpty ? number : title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text(
                            number,
                            style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(label: status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy, fontSize: 18)),
                if (pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final ok = await showZayaConfirm(
                              context,
                              title: l10n.rejectRequestTitle,
                              message: l10n.rejectRequestMessage,
                              confirmLabel: l10n.reject,
                              icon: Icons.cancel_outlined,
                            );
                            if (!ok || !context.mounted) {
                              return;
                            }
                            final error = await context.read<BookingRequestsCubit>().act(id, 'reject');
                            if (error != null && context.mounted) {
                              showZayaSnack(context, error, kind: ZayaSnackKind.error);
                            }
                          },
                          child: Text(l10n.reject),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () async {
                            final ok = await showZayaConfirm(
                              context,
                              title: l10n.confirmRequestTitle,
                              message: l10n.confirmRequestMessage,
                              confirmLabel: l10n.confirm,
                              icon: Icons.check_circle_outline,
                              tone: ZayaConfirmTone.primary,
                            );
                            if (!ok || !context.mounted) {
                              return;
                            }
                            final error = await context.read<BookingRequestsCubit>().act(id, 'confirm');
                            if (error != null && context.mounted) {
                              showZayaSnack(context, error, kind: ZayaSnackKind.error);
                            }
                          },
                          child: Text(l10n.confirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
