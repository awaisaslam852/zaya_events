import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../core/widgets/catalog_request_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/open_conversation.dart';
import '../cubit/venues_cubit.dart';
import '../cubit/venues_state.dart';

class VenuesDetailPage extends StatelessWidget {
  const VenuesDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VenuesCubit>()..loadOne(id),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: BlocBuilder<VenuesCubit, VenuesState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<VenuesCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'VENUE',
                      resourceId: item.id,
                      quickActions: [
                        CatalogQuickAction(
                          icon: Icons.meeting_room_outlined,
                          label: l10n.requestVisit,
                          onTap: () => CatalogRequest.open(
                            context,
                            mode: CatalogRequestMode.visit,
                            resourceType: 'VENUE',
                            resourceId: item.id,
                          ),
                        ),
                        CatalogQuickAction(
                          icon: Icons.mail_outline,
                          label: l10n.inquire,
                          onTap: () => CatalogRequest.open(
                            context,
                            mode: CatalogRequestMode.inquire,
                            resourceType: 'VENUE',
                            resourceId: item.id,
                            needsGuests: true,
                          ),
                        ),
                      ],
                      primaryLabel: l10n.bookNow,
                      onPrimary: () => CatalogRequest.open(
                        context,
                        mode: CatalogRequestMode.book,
                        resourceType: 'VENUE',
                        resourceId: item.id,
                        needsGuests: true,
                      ),
                      secondaryLabel: l10n.addToCart,
                      onSecondary: () => CatalogRequest.open(
                        context,
                        mode: CatalogRequestMode.addToCart,
                        resourceType: 'VENUE',
                        resourceId: item.id,
                        needsGuests: true,
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
