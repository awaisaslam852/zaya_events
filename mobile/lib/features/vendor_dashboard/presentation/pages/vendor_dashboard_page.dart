import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_settings.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/app_refresh.dart';
import '../../../../core/sync/screen_sync.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/localized.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../home/data/banners_repository.dart';
import '../../../notifications/presentation/widgets/notification_bell_button.dart';
import '../../../home/presentation/cubit/banners_cubit.dart';
import '../../../home/presentation/widgets/home_banners.dart';
import '../cubit/vendor_dashboard_cubit.dart';
import '../vendor_dashboard_metrics.dart';

class VendorDashboardPage extends StatelessWidget {
  const VendorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<VendorDashboardCubit>()..load()),
        BlocProvider(
          create: (_) => sl<BannersCubit>()..load(placements: BannersRepository.vendorPlacements),
        ),
      ],
      child: ScreenSync(
        topics: const [
          AppRefreshTopic.vendorDashboard,
          AppRefreshTopic.bookings,
          AppRefreshTopic.visits,
          AppRefreshTopic.vendorCatalog,
        ],
        onRefresh: (context) => context.read<VendorDashboardCubit>().load(silent: true),
        child: const _VendorDashboardView(),
      ),
    );
  }
}

class _VendorDashboardView extends StatelessWidget {
  const _VendorDashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: BlocBuilder<VendorDashboardCubit, VendorDashboardState>(
        builder: (context, state) {
          return AsyncBody(
            loading: state.loading,
            error: state.error,
            empty: state.me == null,
            onRetry: () => context.read<VendorDashboardCubit>().load(),
            child: RefreshIndicator(
              color: AppTheme.navy,
              onRefresh: () =>
                  context.read<VendorDashboardCubit>().load(silent: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _Hero(state: state)),
                  SliverToBoxAdapter(
                    child: BlocBuilder<BannersCubit, BannersState>(
                      builder: (context, banners) {
                        if (banners.items.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: HomeBanners(),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    sliver: SliverList.list(
                      children: [
                        _KpiStrip(state: state),
                        const SizedBox(height: 16),
                        _AttentionBanner(state: state),
                        _SectionTitle(l10n.operations),
                        const SizedBox(height: 10),
                        const _OperationsGrid(),
                        const SizedBox(height: 22),
                        _SectionTitle(
                          l10n.recentBookings,
                          actionLabel: l10n.seeAll,
                          onAction: () => context.push('/vendor/bookings'),
                        ),
                        const SizedBox(height: 10),
                        _RecentBookings(state: state),
                        const SizedBox(height: 22),
                        _SectionTitle(l10n.quickActions),
                        const SizedBox(height: 10),
                        const _MoreTools(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.state});

  final VendorDashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final me = state.me ?? const <String, dynamic>{};
    final metrics = VendorDashboardMetrics(
      state.earnings,
      state.me,
      state.reviews,
    );
    final cover = catalogImageUrl(me);
    final name = localized(me['businessName'], locale);
    final city = me['city']?.toString() ?? '';
    final country = _countryName(me['country']?.toString(), locale);
    final location = [
      city,
      country,
    ].where((part) => part.isNotEmpty).join(' · ');
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l10n.greetingMorning
        : hour < 17
        ? l10n.greetingAfternoon
        : l10n.greetingEvening;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00183D), Color(0xFF003580), Color(0xFF0B5BB5)],
        ),
      ),
      child: Stack(
        children: [
          if (cover != null)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                  child: Opacity(
                    opacity: 0.22,
                    child: CachedNetworkImage(
                      imageUrl: cover,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.paddingOf(context).top + 8,
              12,
              18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 36),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.partnerHub.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const LanguageHeaderActions(),
                    const NotificationBellButton(),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BusinessAvatar(raw: me, name: name),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? l10n.welcomeBack : name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          if (location.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: StatusBadge(
                              label: me['status']?.toString() ?? '',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _EarningsCard(metrics: metrics),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessAvatar extends StatelessWidget {
  const _BusinessAvatar({required this.raw, required this.name});

  final Map<String, dynamic> raw;
  final String name;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.maybeWhen(
      authenticated: (value) => value,
      orElse: () => null,
    );
    final image = catalogImageUrl(raw) ?? (user == null ? null : profileImageUrl(user));
    final trimmed = name.trim();
    final initial = trimmed.isEmpty
        ? (user == null ? 'Z' : profileInitials(user))
        : trimmed.substring(0, 1).toUpperCase();
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12),
        ],
      ),
      child: ZayaAvatar(
        url: image,
        initials: initial,
        radius: 29,
        backgroundColor: AppTheme.yellow,
        foregroundColor: const Color(0xFF1A1A1A),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.metrics});

  final VendorDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/vendor/earnings'),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFEBB02), Color(0xFFFFE28A)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFEBB02).withValues(alpha: 0.38),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.payments_rounded, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.earnings,
                      style: const TextStyle(
                        color: Color(0xFF5B4A00),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatMoney(metrics.totalAmount, metrics.currency),
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${metrics.bookingCount} ${l10n.bookings.toLowerCase()} · ${metrics.occupancy} ${l10n.occupancy.toLowerCase()}',
                      style: const TextStyle(
                        color: Color(0xFF5B4A00),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF1A1A1A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.state});

  final VendorDashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = VendorDashboardMetrics(
      state.earnings,
      state.me,
      state.reviews,
    );
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.meeting_room_outlined,
            label: l10n.occupancy,
            value: metrics.occupancy,
            colors: const [Color(0xFF003580), Color(0xFF0B5BB5)],
            onTap: () => context.go('/vendor/requests'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.inbox_outlined,
            label: l10n.requests,
            value: '${metrics.pendingCount}',
            colors: const [Color(0xFFE2A800), Color(0xFFFEBB02)],
            darkText: true,
            onTap: () => context.go('/vendor/requests'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.star_rounded,
            label: l10n.reviews,
            value: metrics.rating,
            colors: const [Color(0xFF0F7B3A), Color(0xFF2BB673)],
            onTap: () => context.push('/vendor/reviews'),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.onTap,
    this.darkText = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final fg = darkText ? const Color(0xFF1A1A1A) : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: darkText ? 0.45 : 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: fg, size: 18),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.82),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttentionBanner extends StatelessWidget {
  const _AttentionBanner({required this.state});

  final VendorDashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = VendorDashboardMetrics(
      state.earnings,
      state.me,
      state.reviews,
    );
    final status = (state.me?['status']?.toString() ?? '').toUpperCase();
    if (metrics.pendingCount == 0 && (status.isEmpty || status == 'APPROVED')) {
      return const SizedBox.shrink();
    }
    final message = !metrics.isApproved && status.isNotEmpty
        ? l10n.underReview
        : l10n.pendingRequestsHint('${metrics.pendingCount}');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: const Color(0xFFFFF6D8),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.go('/vendor/requests'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.yellow,
                  child: Icon(
                    Icons.priority_high_rounded,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.needsAttention,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 13,
                          height: 1.3,
                        ),
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
    );
  }
}

class _OperationsGrid extends StatelessWidget {
  const _OperationsGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      _OpItem(
        Icons.add_home_work_outlined,
        l10n.myCatalog,
        l10n.addProduct,
        const [Color(0xFFDCEBFA), Color(0xFFB7D4F5)],
        AppTheme.navy,
        () => context.go('/vendor/listings'),
      ),
      _OpItem(
        Icons.calendar_month_outlined,
        l10n.calendar,
        l10n.availability,
        const [Color(0xFFFFF4CC), Color(0xFFFFE08A)],
        const Color(0xFF8A6A00),
        () => context.push('/vendor/calendar'),
      ),
      _OpItem(
        Icons.chat_bubble_outline_rounded,
        l10n.chat,
        l10n.typeMessage,
        const [Color(0xFFE3F7EC), Color(0xFFB7E8C8)],
        const Color(0xFF0F7B3A),
        () => context.go('/vendor/chat'),
      ),
      _OpItem(
        Icons.receipt_long_outlined,
        l10n.bookingHistory,
        l10n.seeAll,
        const [Color(0xFFFFE8E4), Color(0xFFFFC9C0)],
        const Color(0xFFB42318),
        () => context.push('/vendor/bookings'),
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.12,
      children: items
          .map(
            (item) => _OperationTile(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              colors: item.colors,
              accent: item.accent,
              onTap: item.onTap,
            ),
          )
          .toList(),
    );
  }
}

class _OpItem {
  const _OpItem(this.icon, this.title, this.subtitle, this.colors, this.accent, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accent),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: accent),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: accent.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentBookings extends StatelessWidget {
  const _RecentBookings({required this.state});

  final VendorDashboardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookings = VendorDashboardMetrics(
      state.earnings,
      state.me,
      state.reviews,
    ).bookings.take(4).toList();
    if (bookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4EDF7)),
        ),
        child: Text(
          l10n.noBookingsYet,
          style: const TextStyle(color: AppTheme.muted, height: 1.4),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EDF7)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < bookings.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEAF1F8)),
            _BookingRow(booking: bookings[i]),
          ],
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.booking});

  final Map<String, dynamic> booking;

  @override
  Widget build(BuildContext context) {
    final number =
        booking['bookingNumber']?.toString() ?? booking['id']?.toString() ?? '';
    final amount = booking['totalAmount'];
    final currency = booking['currency']?.toString();
    final status = booking['status']?.toString() ?? '';
    final created = DateTime.tryParse(booking['createdAt']?.toString() ?? '');
    final date = created == null
        ? ''
        : DateFormat.MMMd(
            Localizations.localeOf(context).toString(),
          ).format(created.toLocal());
    final money = amount == null
        ? ''
        : _formatMoney(num.tryParse(amount.toString()) ?? 0, currency);
    return InkWell(
      onTap: () {
        final id = booking['id']?.toString();
        if (id != null && id.isNotEmpty) {
          context.push('/bookings/$id');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _bookingTint(status).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_long_outlined, color: _bookingTint(status), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [money, date].where((part) => part.isNotEmpty).join(' · '),
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            StatusBadge(label: status),
          ],
        ),
      ),
    );
  }
}

class _MoreTools extends StatelessWidget {
  const _MoreTools();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.payments_outlined, l10n.earnings, '/vendor/earnings', const Color(0xFFFFF4CC), const Color(0xFF8A6A00)),
      (Icons.receipt_long_outlined, l10n.bookingHistory, '/vendor/bookings', const Color(0xFFDCEBFA), AppTheme.navy),
      (Icons.calendar_month_outlined, l10n.calendar, '/vendor/calendar', const Color(0xFFE3F7EC), const Color(0xFF0F7B3A)),
      (Icons.meeting_room_outlined, l10n.venueVisits, '/vendor/visits', const Color(0xFFEEE4FF), const Color(0xFF6D28D9)),
      (Icons.star_outline_rounded, l10n.reviews, '/vendor/reviews', const Color(0xFFFFE8C8), const Color(0xFFB45309)),
      (Icons.storefront_outlined, l10n.vendorProfile, '/vendor/business', const Color(0xFFFFE4E0), const Color(0xFFB42318)),
      (Icons.notifications_none_rounded, l10n.notifications, '/notifications', const Color(0xFFE8F0FE), AppTheme.blue),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Material(
            color: item.$4,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.push(item.$3),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.$1, color: item.$5, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      item.$2,
                      style: TextStyle(fontWeight: FontWeight.w800, color: item.$5, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.ink,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

Color _bookingTint(String status) {
  return switch (status.toUpperCase()) {
    'CONFIRMED' || 'PAID' || 'APPROVED' || 'COMPLETED' => const Color(0xFF0F7B3A),
    'INQUIRY' || 'PENDING' || 'UNDER_REVIEW' => const Color(0xFFB45309),
    'CANCELLED' || 'REJECTED' => const Color(0xFFB42318),
    _ => AppTheme.navy,
  };
}

String _formatMoney(num amount, String? currency) {
  final code = appCurrency(fallback: currency);
  final formatted = amount
      .toStringAsFixed(amount % 1 == 0 ? 0 : 0)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (match) => '${match[1]},',
      );
  return '$code $formatted';
}

String _countryName(String? code, String locale) {
  if (code == null || code.isEmpty) {
    return '';
  }
  for (final country in kCountries) {
    if (country.code == code) {
      return country.localizedName(locale);
    }
  }
  return code;
}
