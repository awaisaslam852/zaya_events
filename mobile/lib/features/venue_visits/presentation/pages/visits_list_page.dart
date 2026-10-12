import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/json_title.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/visits_cubit.dart';
import '../cubit/visits_state.dart';

class VisitsListPage extends StatelessWidget {
  const VisitsListPage({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VisitsCubit>()..load(),
      child: Scaffold(
        appBar: embedded ? null : AppBar(title: Text(l10n.venueVisits)),
        body: BlocBuilder<VisitsCubit, VisitsState>(
          builder: (context, state) {
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: state.items.isEmpty,
              onRetry: () => context.read<VisitsCubit>().load(),
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final title = item.raw['title'] ?? item.raw['name'] ?? item.raw['businessName'] ?? item.id;
                  return ListTile(
                    title: JsonTitle(title),
                    subtitle: Text(item.raw['city']?.toString() ?? item.raw['status']?.toString() ?? ''),
                    onTap: () => context.push('/venue_visits/${item.id}'),
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
