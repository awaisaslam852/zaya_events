import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../features/cart/cart_cubit.dart';
import '../../features/notifications/presentation/cubit/unread_notifications_cubit.dart';
import 'app_refresh.dart';

/// Reloads a screen when a matching [AppRefresh] ping fires, or the app resumes.
class ScreenSync extends StatefulWidget {
  const ScreenSync({
    super.key,
    required this.topics,
    required this.onRefresh,
    required this.child,
    this.refreshOnResume = true,
  });

  final List<AppRefreshTopic> topics;
  final Future<void> Function(BuildContext context) onRefresh;
  final Widget child;
  final bool refreshOnResume;

  @override
  State<ScreenSync> createState() => _ScreenSyncState();
}

class _ScreenSyncState extends State<ScreenSync> with WidgetsBindingObserver {
  StreamSubscription<AppRefreshTopic>? _sub;
  Timer? _debounce;
  var _busy = false;
  var _queued = false;

  @override
  void initState() {
    super.initState();
    if (widget.refreshOnResume) {
      WidgetsBinding.instance.addObserver(this);
    }
    _sub = AppRefresh.instance.stream.listen((topic) {
      if (widget.topics.contains(topic)) {
        _schedule();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(_sub?.cancel());
    if (widget.refreshOnResume) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _schedule();
    }
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), _run);
  }

  Future<void> _run() async {
    if (!mounted) {
      return;
    }
    if (_busy) {
      _queued = true;
      return;
    }
    _busy = true;
    do {
      _queued = false;
      await widget.onRefresh(context);
    } while (_queued && mounted);
    _busy = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Keeps tab badges (unread + cart) in sync while the shell stays mounted.
class ShellBadgeSync extends StatelessWidget {
  const ShellBadgeSync({super.key, required this.child, this.includeCart = false});

  final Widget child;
  final bool includeCart;

  @override
  Widget build(BuildContext context) {
    return ScreenSync(
      topics: [
        AppRefreshTopic.notifications,
        if (includeCart) AppRefreshTopic.cart,
      ],
      onRefresh: (_) => refreshShellBadges(includeCart: includeCart),
      child: child,
    );
  }
}

Future<void> refreshShellBadges({required bool includeCart}) async {
  final getIt = GetIt.instance;
  if (getIt.isRegistered<UnreadNotificationsCubit>()) {
    await getIt<UnreadNotificationsCubit>().refresh();
  }
  if (includeCart && getIt.isRegistered<CartCubit>()) {
    await getIt<CartCubit>().load(silent: true);
  }
}
