import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/vendor_dashboard_cubit.dart';

class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorDashboardCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
          builder: (context, state) {
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.me == null,
              onRetry: () => context.read<VendorDashboardCubit>().load(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ScreenHeader(
                    eyebrow: l10n.partnerHub,
                    title: l10n.welcomeBack,
                    subtitle: l10n.partnerSubtitle,
                    trailing: const LanguageHeaderActions(),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.navy,
                                child: Icon(Icons.storefront, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    JsonTitle(
                                      state.me?['businessName'],
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(label: state.me?['status']?.toString() ?? ''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.35,
                          children: [
                            _Kpi(
                              icon: Icons.payments_outlined,
                              label: l10n.earnings,
                              value: _money(state.earnings?['totals']),
                              onTap: () => context.push('/vendor/earnings'),
                            ),
                            _Kpi(
                              icon: Icons.meeting_room_outlined,
                              label: l10n.occupancy,
                              value: _occupancy(state.earnings),
                              onTap: () => context.go('/vendor/requests'),
                            ),
                            _Kpi(
                              icon: Icons.inbox_outlined,
                              label: l10n.requests,
                              value: '${_bookingCount(state.earnings)}',
                              onTap: () => context.go('/vendor/requests'),
                            ),
                            _Kpi(
                              icon: Icons.star_outline,
                              label: l10n.reviews,
                              value: _rating(state.me, state.reviews),
                              onTap: () => context.push('/vendor/reviews'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(l10n.quickActions, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.15,
                          children: [
                            ActionTile(
                              icon: Icons.add_box_outlined,
                              title: l10n.listings,
                              subtitle: l10n.photos,
                              onTap: () => context.go('/vendor/listings'),
                            ),
                            ActionTile(
                              icon: Icons.calendar_month_outlined,
                              title: l10n.calendar,
                              subtitle: l10n.availability,
                              onTap: () => context.push('/vendor/calendar'),
                            ),
                            ActionTile(
                              icon: Icons.chat_bubble_outline,
                              title: l10n.chat,
                              subtitle: l10n.typeMessage,
                              onTap: () => context.go('/vendor/chat'),
                            ),
                            ActionTile(
                              icon: Icons.star_outline,
                              title: l10n.reviews,
                              subtitle: l10n.reviews,
                              onTap: () => context.push('/vendor/reviews'),
                            ),
                          ],
                        ),
                      ],
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

  static String _money(dynamic totals) {
    if (totals is Map) {
      return totals['total']?.toString() ?? totals.values.firstOrNull?.toString() ?? '0';
    }
    return totals?.toString() ?? '0';
  }

  static int _bookingCount(Map<String, dynamic>? earnings) {
    return (earnings?['bookings'] as List?)?.length ?? 0;
  }

  static String _occupancy(Map<String, dynamic>? earnings) {
    final bookings = (earnings?['bookings'] as List?) ?? [];
    if (bookings.isEmpty) {
      return '—';
    }
    final busy = bookings.where((row) {
      final status = (row is Map ? row['status'] : null)?.toString().toUpperCase() ?? '';
      return status == 'CONFIRMED' || status == 'PAID' || status == 'COMPLETED';
    }).length;
    return '${((busy / bookings.length) * 100).round()}%';
  }

  static String _rating(Map<String, dynamic>? me, Map<String, dynamic>? reviews) {
    final avg = reviews?['ratingAvg'] ?? me?['ratingAvg'];
    final count = reviews?['ratingCount'] ?? me?['ratingCount'] ?? 0;
    if (avg == null) {
      return '—';
    }
    return '$avg · $count';
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.blue),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.navy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
