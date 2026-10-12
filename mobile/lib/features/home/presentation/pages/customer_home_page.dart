import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/zaya_chrome.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cars/presentation/cubit/cars_cubit.dart';
import '../../../cars/presentation/cubit/cars_state.dart';
import '../../../venues/presentation/cubit/venues_cubit.dart';
import '../../../venues/presentation/cubit/venues_state.dart';
import '../cubit/banners_cubit.dart';
import '../widgets/home_banners.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chips = [
      (l10n.venues, '/customer/venues', Icons.apartment_outlined),
      (l10n.vendors, '/customer/vendors', Icons.storefront_outlined),
      (l10n.cars, '/customer/cars', Icons.directions_car_outlined),
      (l10n.accommodations, '/customer/stays', Icons.hotel_outlined),
      (l10n.honeymoon, '/customer/honeymoon', Icons.favorite_outline),
      (l10n.bookings, '/customer/bookings', Icons.receipt_long_outlined),
    ];
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<VenuesCubit>()..load()),
        BlocProvider(create: (_) => sl<CarsCubit>()..load()),
        BlocProvider(create: (_) => sl<BannersCubit>()..load()),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppTheme.navy,
                padding: const EdgeInsets.fromLTRB(20, 52, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'ZAYA',
                          style: TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, letterSpacing: 2),
                        ),
                        const Spacer(),
                        const LanguageHeaderActions(),
                        IconButton(
                          onPressed: () => context.push('/notifications'),
                          icon: const Icon(Icons.notifications_none, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.tagline, style: const TextStyle(color: Colors.white70, height: 1.35)),
                    const SizedBox(height: 16),
                    ZayaSearchField(
                      hint: l10n.searchHint,
                      onTap: () => context.push('/customer/venues'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: chips.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final chip = chips[index];
                    return CategoryChip(
                      icon: chip.$3,
                      label: chip.$1,
                      onTap: () => context.push(chip.$2),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
                child: HomeBanners(),
              ),
            ),
            SliverToBoxAdapter(
              child: ZayaSectionHeader(
                title: l10n.recommendedVenues,
                actionLabel: l10n.seeAll,
                onAction: () => context.push('/customer/venues'),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<VenuesCubit, VenuesState>(
                builder: (context, state) {
                  return CatalogRail(
                    loading: state.loading,
                    itemCount: state.items.length,
                    rawAt: (index) => state.items[index].raw,
                    onTap: (index) => context.push('/venues/${state.items[index].id}'),
                    emptyLabel: l10n.empty,
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: ZayaSectionHeader(
                title: l10n.recommendedCars,
                actionLabel: l10n.seeAll,
                onAction: () => context.push('/customer/cars'),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<CarsCubit, CarsState>(
                builder: (context, state) {
                  return CatalogRail(
                    loading: state.loading,
                    itemCount: state.items.length,
                    rawAt: (index) => state.items[index].raw,
                    onTap: (index) => context.push('/cars/${state.items[index].id}'),
                    emptyLabel: l10n.empty,
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}
