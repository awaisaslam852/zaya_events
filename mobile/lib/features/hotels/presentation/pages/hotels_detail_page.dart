import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/hotels_cubit.dart';
import '../cubit/hotels_state.dart';

class HotelsDetailPage extends StatelessWidget {
  const HotelsDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<HotelsCubit>()..loadOne(id),
      child: Scaffold(
        body: BlocBuilder<HotelsCubit, HotelsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<HotelsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'HOTEL',
                      resourceId: item.id,
                      primaryLabel: l10n.bookNow,
                      onPrimary: () async {
                        final checkIn = DateTime.now().add(const Duration(days: 14));
                        final error = await context.read<HotelsCubit>().book(
                          id,
                          checkIn: checkIn,
                          checkOut: checkIn.add(const Duration(days: 3)),
                        );
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? l10n.saveSuccess)));
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
