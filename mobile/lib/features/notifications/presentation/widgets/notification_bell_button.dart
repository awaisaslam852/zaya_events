import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/unread_notifications_cubit.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key, this.light = true});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: sl<UnreadNotificationsCubit>()..ensureLoaded(),
      child: BlocBuilder<UnreadNotificationsCubit, int>(
        builder: (context, count) {
          final color = light ? Colors.white : AppTheme.navy;
          final label = unreadBadgeLabel(count);
          return IconButton(
            tooltip: l10n.notifications,
            onPressed: () async {
              await context.push('/notifications');
              if (sl.isRegistered<UnreadNotificationsCubit>()) {
                await sl<UnreadNotificationsCubit>().refresh();
              }
            },
            icon: Badge(
              isLabelVisible: count > 0,
              backgroundColor: AppTheme.yellow,
              textColor: const Color(0xFF1A1A1A),
              label: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
              ),
              child: Icon(
                count > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                color: color,
              ),
            ),
          );
        },
      ),
    );
  }
}
