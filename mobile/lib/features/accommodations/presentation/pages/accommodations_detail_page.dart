import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/accommodations_cubit.dart';
import '../cubit/accommodations_state.dart';

class AccommodationsDetailPage extends StatelessWidget {
  const AccommodationsDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<AccommodationsCubit>()..loadOne(id),
      child: Scaffold(
        body: BlocBuilder<AccommodationsCubit, AccommodationsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<AccommodationsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'ACCOMMODATION',
                      resourceId: item.id,
                      primaryLabel: l10n.bookNow,
                      onPrimary: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.availabilitySent)));
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
