import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/flights_cubit.dart';
import '../cubit/flights_state.dart';

class FlightsDetailPage extends StatelessWidget {
  const FlightsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _book(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final error = await context.read<FlightsCubit>().book(id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? l10n.saveSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<FlightsCubit>()..loadOne(id),
      child: Scaffold(
        body: BlocBuilder<FlightsCubit, FlightsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<FlightsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'FLIGHT',
                      resourceId: item.id,
                      enableFavorite: false,
                      extras: [
                        if ((item.raw['origin'] ?? item.raw['destination']) != null)
                          Row(
                            children: [
                              const Icon(Icons.flight_takeoff, size: 18, color: AppTheme.blue),
                              const SizedBox(width: 8),
                              Text('${item.raw['origin'] ?? ''} → ${item.raw['destination'] ?? ''}'),
                            ],
                          ),
                        if (item.raw['departureAt'] != null)
                          Text(item.raw['departureAt'].toString().replaceFirst('T', ' ').split('.').first),
                      ],
                      primaryLabel: l10n.bookFlight,
                      onPrimary: () => _book(context),
                    ),
            );
          },
        ),
      ),
    );
  }
}
