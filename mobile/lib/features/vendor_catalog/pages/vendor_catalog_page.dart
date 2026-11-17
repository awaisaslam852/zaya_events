import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart';
import '../../../core/sync/app_refresh.dart';
import '../../../core/sync/screen_sync.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_body.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/zaya_dialogs.dart';
import '../../../l10n/app_localizations.dart';
import '../vendor_catalog_cubit.dart';
import '../vendor_catalog_kind.dart';

class VendorCatalogPage extends StatelessWidget {
  const VendorCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VendorCatalogCubit>()..load(VendorCatalogKind.all),
      child: ScreenSync(
        topics: const [AppRefreshTopic.vendorCatalog],
        onRefresh: (context) =>
            context.read<VendorCatalogCubit>().load(context.read<VendorCatalogCubit>().state.kind, silent: true),
        child: const _VendorCatalogView(),
      ),
    );
  }
}

class _VendorCatalogView extends StatelessWidget {
  const _VendorCatalogView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(
            eyebrow: l10n.listings,
            title: l10n.myCatalog,
            subtitle: l10n.catalogSubtitle,
            trailing: FilledButton.icon(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addProduct),
            ),
          ),
          const _KindChips(),
          Expanded(
            child: BlocBuilder<VendorCatalogCubit, VendorCatalogState>(
              builder: (context, state) {
                return AsyncBody(
                  loading: state.loading,
                  error: state.error,
                  empty: state.items.isEmpty,
                  emptyIcon: Icons.storefront_outlined,
                  emptyTitle: l10n.empty,
                  emptyMessage: l10n.catalogSubtitle,
                  emptyActionLabel: l10n.addProduct,
                  onEmptyAction: () => _add(context),
                  onRetry: () =>
                      context.read<VendorCatalogCubit>().load(state.kind),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CatalogTile(
                        raw: state.items[index],
                        kind: catalogKindOf(state.items[index], state.kind),
                        showType: state.kind.isAggregate,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<VendorCatalogCubit>();
    final l10n = AppLocalizations.of(context);
    var kind = cubit.state.kind;
    if (kind.isAggregate) {
      final picked = await showZayaSheet<VendorCatalogKind>(
        context: context,
        child: ZayaSheetScaffold(
          title: l10n.chooseListingType,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in VendorCatalogKind.sellable)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.wash,
                      child: Icon(option.icon, color: AppTheme.navy),
                    ),
                    title: Text(
                      option.label(l10n),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context, option),
                  ),
              ],
            ),
          ),
        ),
      );
      if (picked == null || !context.mounted) {
        return;
      }
      kind = picked;
    }
    final created = await context.push<bool>(kind.newPath);
    if (context.mounted && created == true) {
      cubit.load(cubit.state.kind);
    }
  }
}

class _KindChips extends StatelessWidget {
  const _KindChips();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = context.watch<VendorCatalogCubit>().state.kind;
    final chips = [
      for (final kind in VendorCatalogKind.values) (kind, kind.label(l10n)),
    ];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final selected = chip.$1 == current;
          return ChoiceChip(
            label: Text(chip.$2),
            selected: selected,
            selectedColor: AppTheme.yellow,
            onSelected: (_) => context.read<VendorCatalogCubit>().load(chip.$1),
          );
        },
      ),
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.raw,
    required this.kind,
    this.showType = false,
  });

  final Map<String, dynamic> raw;
  final VendorCatalogKind kind;
  final bool showType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final title = catalogTitle(raw, locale);
    final image = catalogImageUrl(raw);
    final published = raw['isPublished'] == true;
    final id = raw['id']?.toString() ?? '';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          if (id.isEmpty) {
            return;
          }
          final changed = await context.push<bool>(kind.editPath(id));
          if (context.mounted && changed == true) {
            context.read<VendorCatalogCubit>().load(kind);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4EDF7)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: image == null
                      ? const ColoredBox(
                          color: AppTheme.wash,
                          child: Icon(
                            Icons.storefront_outlined,
                            color: AppTheme.navy,
                          ),
                        )
                      : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (showType) StatusBadge(label: kind.label(l10n)),
                        StatusBadge(
                          label: published ? l10n.publish : l10n.unpublish,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _act(context, value, id, published, title),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(published ? l10n.unpublish : l10n.publish),
                  ),
                  PopupMenuItem(value: 'delete', child: Text(l10n.deleteItem)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _act(
    BuildContext context,
    String value,
    String id,
    bool published,
    String title,
  ) async {
    final cubit = context.read<VendorCatalogCubit>();
    final l10n = AppLocalizations.of(context);
    if (value == 'toggle') {
      if (published) {
        final ok = await showZayaConfirm(
          context,
          title: l10n.unpublishTitle,
          message: l10n.unpublishMessage(title),
          confirmLabel: l10n.unpublish,
          icon: Icons.visibility_off_outlined,
          tone: ZayaConfirmTone.neutral,
        );
        if (!ok || !context.mounted) {
          return;
        }
      }
      final error = await cubit.setPublished(kind, id, !published);
      if (context.mounted && error != null) {
        showZayaSnack(context, error, kind: ZayaSnackKind.error);
      }
      return;
    }
    final confirmed = await showZayaConfirm(
      context,
      title: l10n.deleteCatalogTitle,
      message: l10n.deleteCatalogMessage(title),
      confirmLabel: l10n.deleteItem,
      icon: Icons.delete_outline,
    );
    if (confirmed == true) {
      final error = await cubit.remove(kind, id);
      if (context.mounted && error != null) {
        showZayaSnack(context, error, kind: ZayaSnackKind.error);
      }
    }
  }
}
