import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/accommodations_cubit.dart';
import '../cubit/accommodations_state.dart';

class AccommodationsListPage extends StatelessWidget {
  const AccommodationsListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<AccommodationsCubit>()..load(),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.accommodations)),
        body: BlocBuilder<AccommodationsCubit, AccommodationsState>(
          builder: (context, state) {
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.items.isEmpty,
              onRetry: () => context.read<AccommodationsCubit>().load(),
              child: CatalogFeed(
                itemCount: state.items.length,
                rawAt: (index) => state.items[index].raw,
                onTap: (index) => context.push('/accommodations/${state.items[index].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
