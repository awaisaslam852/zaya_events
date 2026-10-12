import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/app_role.dart';
import 'nav_destinations.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: RoleNavBar(
        role: AppRole.customer,
        selectedIndex: tabIndexForPath(location, customerTabPaths),
        onDestinationSelected: (index) => context.go(customerTabPaths[index]),
      ),
    );
  }
}
