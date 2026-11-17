import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/app_role.dart';
import '../../core/sync/screen_sync.dart';
import 'nav_destinations.dart';

class VendorShell extends StatelessWidget {
  const VendorShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return ShellBadgeSync(
      child: Scaffold(
        body: child,
        bottomNavigationBar: RoleNavBar(
          role: AppRole.vendor,
          selectedIndex: tabIndexForPath(location, vendorTabPaths),
          onDestinationSelected: (index) => context.go(vendorTabPaths[index]),
        ),
      ),
    );
  }
}
