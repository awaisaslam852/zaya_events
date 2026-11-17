import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/open_conversation.dart';
import '../cubit/vendors_cubit.dart';
import '../cubit/vendors_state.dart';

class VendorsDetailPage extends StatelessWidget {
  const VendorsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _openChat(BuildContext context, Map<String, dynamic> raw) async {
    final userId = raw['userId']?.toString() ??
        (raw['user'] is Map ? (raw['user'] as Map)['id']?.toString() : null);
    await openConversation(context, participantId: userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorsCubit>()..loadOne(id),
      child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: BlocBuilder<VendorsCubit, VendorsState>(
          builder: (context, state) {
            final item = state.detail;
            return AsyncBody(
              loading: state.loading,
              error: state.error,
              empty: item == null,
              onRetry: () => context.read<VendorsCubit>().loadOne(id),
              child: item == null
                  ? const SizedBox.shrink()
                  : CatalogDetailView(
                      raw: item.raw,
                      resourceType: 'VENDOR',
                      resourceId: item.id,
                      primaryLabel: l10n.chat,
                      onPrimary: () => _openChat(context, item.raw),
                      secondaryLabel: l10n.inquire,
                      onSecondary: () => _openChat(context, item.raw),
                    ),
            );
          },
        ),
      ),
    );
  }
}
