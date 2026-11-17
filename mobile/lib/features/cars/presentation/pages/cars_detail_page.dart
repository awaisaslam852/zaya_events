import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../core/widgets/catalog_request_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/open_conversation.dart';
import '../cubit/cars_cubit.dart';
import '../cubit/cars_state.dart';

class CarsDetailPage extends StatelessWidget {
  const CarsDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<CarsCubit>()..loadOne(id),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: BlocBuilder<CarsCubit, CarsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<CarsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'CAR',
                      resourceId: item.id,
                      primaryLabel: l10n.bookNow,
                      onPrimary: () => CatalogRequest.open(
                        context,
                        mode: CatalogRequestMode.book,
                        resourceType: 'CAR',
                        resourceId: item.id,
                        needsEndDate: true,
                      ),
                      secondaryLabel: l10n.addToCart,
                      onSecondary: () => CatalogRequest.open(
                        context,
                        mode: CatalogRequestMode.addToCart,
                        resourceType: 'CAR',
                        resourceId: item.id,
                        needsEndDate: true,
                      ),
                      onChat: onVendorChat(context, item.raw),
                    ),
            );
          },
        ),
      ),
    );
  }
}
