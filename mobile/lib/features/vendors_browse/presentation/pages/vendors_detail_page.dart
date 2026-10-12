import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/async_body.dart';
import '../../../../core/widgets/catalog_detail.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../chat/domain/chat_usecases.dart';
import '../cubit/vendors_cubit.dart';
import '../cubit/vendors_state.dart';

class VendorsDetailPage extends StatelessWidget {
  const VendorsDetailPage({super.key, required this.id});
  final String id;

  Future<void> _openChat(BuildContext context, Map<String, dynamic> raw) async {
    final l10n = AppLocalizations.of(context);
    final userId = raw['userId']?.toString() ??
        (raw['user'] is Map ? (raw['user'] as Map)['id']?.toString() : null);
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      return;
    }
    final result = await sl<StartConversation>()(userId);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      (convo) => context.push('/chat/${convo['id']}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => sl<VendorsCubit>()..loadOne(id),
      child: Scaffold(
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
