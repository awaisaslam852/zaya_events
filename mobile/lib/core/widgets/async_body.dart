import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../l10n/app_localizations.dart';
import 'screen_header.dart';

class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.loading,
    required this.error,
    required this.empty,
    required this.child,
    this.onRetry,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
  });

  final bool loading;
  final String? error;
  final bool empty;
  final Widget child;
  final VoidCallback? onRetry;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (loading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (_, _) => Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!),
            if (onRetry != null) TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      );
    }
    if (empty) {
      return EmptyHero(
        icon: emptyIcon ?? Icons.search_off,
        title: emptyTitle ?? l10n.empty,
        message: emptyMessage ?? l10n.empty,
        actionLabel: emptyActionLabel,
        onAction: onEmptyAction ?? onRetry,
      );
    }
    return child;
  }
}
