import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/sync/app_refresh.dart';
import '../../core/sync/screen_sync.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/customer_hub.dart';
import '../../core/utils/localized.dart';
import '../../core/widgets/async_body.dart';
import '../../core/widgets/property_card.dart';
import '../../core/widgets/screen_header.dart';
import '../../core/widgets/zaya_dialogs.dart';
import '../../core/widgets/zaya_fields.dart';
import '../../l10n/app_localizations.dart';
import 'cart_cubit.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: sl<CartCubit>()..load(),
      child: ScreenSync(
        topics: const [AppRefreshTopic.cart],
        onRefresh: (context) => context.read<CartCubit>().load(silent: true),
        child: Scaffold(
        backgroundColor: AppTheme.canvas,
        body: Column(
          children: [
            ScreenHeader(showBack: true, eyebrow: l10n.cart, title: l10n.cart, subtitle: l10n.cartSubtitle),
            Expanded(
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  return AsyncBody(
                    loading: state.loading && state.items.isEmpty,
                    error: state.error,
                    empty: state.items.isEmpty,
                    emptyIcon: Icons.shopping_bag_outlined,
                    emptyTitle: l10n.cartEmpty,
                    emptyMessage: l10n.cartSubtitle,
                    emptyActionLabel: l10n.browseToBook,
                    onEmptyAction: () => context.push('/customer/venues'),
                    onRetry: () => context.read<CartCubit>().load(),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            itemCount: state.items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              final locale = Localizations.localeOf(context).languageCode;
                              final type = item['type']?.toString();
                              final start = item['startAt']?.toString().split('T').first ?? '';
                              final end = item['endAt']?.toString().split('T').first;
                              final image = item['imageUrl']?.toString() ?? '';
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.line),
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: SizedBox(
                                          width: 72,
                                          height: 72,
                                          child: image.isEmpty
                                              ? ColoredBox(
                                                  color: favoriteTypeWash(type),
                                                  child: Icon(bookingTypeIcon(type), color: AppTheme.navy),
                                                )
                                              : Image.network(resolveMediaUrl(image), fit: BoxFit.cover),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              localized(item['title'], locale),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              [
                                                bookingTypeLabel(l10n, type),
                                                if (start.isNotEmpty) start,
                                                if (end != null && end.isNotEmpty) end,
                                              ].join(' · '),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              formatMoney(item['unitAmount'], item['currency']?.toString() ?? state.currency),
                                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFB00020)),
                                        onPressed: () async {
                                          final ok = await showZayaConfirm(
                                            context,
                                            title: l10n.removeCartTitle,
                                            message: l10n.removeCartMessage,
                                            confirmLabel: l10n.remove,
                                            icon: Icons.remove_shopping_cart_outlined,
                                          );
                                          if (!ok || !context.mounted) {
                                            return;
                                          }
                                          await context.read<CartCubit>().remove(item['id'].toString());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Material(
                          color: Colors.white,
                          elevation: 12,
                          shadowColor: AppTheme.navy.withValues(alpha: 0.12),
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(l10n.costOverview, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      const Spacer(),
                                      Text(
                                        formatMoney(state.subtotal, state.currency),
                                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(l10n.payDeposit, style: const TextStyle(color: AppTheme.muted)),
                                      const Spacer(),
                                      Text(formatMoney(state.depositTotal, state.currency)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ZayaPrimaryButton(
                                    label: l10n.checkout,
                                    icon: Icons.lock_outline,
                                    busy: state.checkingOut,
                                    onPressed: state.checkingOut
                                        ? null
                                        : () async {
                                            final error = await context.read<CartCubit>().checkout();
                                            if (!context.mounted) {
                                              return;
                                            }
                                            if (error != null) {
                                              showZayaSnack(context, error, kind: ZayaSnackKind.error);
                                            }
                                            if (error == null || sl<CartCubit>().state.items.isEmpty) {
                                              context.go('/customer/bookings');
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
