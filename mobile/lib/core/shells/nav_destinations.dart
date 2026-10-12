import 'package:flutter/material.dart';
import '../../core/auth/app_role.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class NavItem {
  const NavItem({required this.path, required this.icon, required this.activeIcon, required this.label});
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

List<NavItem> customerNavItems(AppLocalizations l10n) {
  return [
    NavItem(path: '/customer/home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: l10n.home),
    NavItem(path: '/customer/events', icon: Icons.celebration_outlined, activeIcon: Icons.celebration, label: l10n.myEvents),
    NavItem(path: '/customer/chat', icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: l10n.chat),
    NavItem(path: '/customer/favorites', icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded, label: l10n.favorites),
    NavItem(path: '/customer/profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: l10n.profile),
  ];
}

List<NavItem> vendorNavItems(AppLocalizations l10n) {
  return [
    NavItem(path: '/vendor/dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: l10n.dashboard),
    NavItem(path: '/vendor/listings', icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: l10n.listings),
    NavItem(path: '/vendor/requests', icon: Icons.inbox_outlined, activeIcon: Icons.inbox_rounded, label: l10n.requests),
    NavItem(path: '/vendor/chat', icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: l10n.chat),
    NavItem(path: '/vendor/profile', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: l10n.profile),
  ];
}

const customerTabPaths = [
  '/customer/home',
  '/customer/events',
  '/customer/chat',
  '/customer/favorites',
  '/customer/profile',
];

const vendorTabPaths = [
  '/vendor/dashboard',
  '/vendor/listings',
  '/vendor/requests',
  '/vendor/chat',
  '/vendor/profile',
];

String homePathForRole(AppRole role) {
  switch (role) {
    case AppRole.vendor:
      return '/vendor/dashboard';
    case AppRole.admin:
      return '/admin-redirect';
    case AppRole.customer:
      return '/customer/home';
  }
}

int tabIndexForPath(String location, List<String> tabPaths) {
  final index = tabPaths.indexWhere((path) => location == path || location.startsWith('$path/'));
  return index < 0 ? 0 : index;
}

class RoleNavBar extends StatelessWidget {
  const RoleNavBar({
    super.key,
    required this.role,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final AppRole role;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = role == AppRole.vendor ? vendorNavItems(l10n) : customerNavItems(l10n);
    final safeIndex = selectedIndex.clamp(0, items.length - 1);
    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: AppTheme.navy.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _TabButton(
                    item: items[i],
                    selected: i == safeIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.item, required this.selected, required this.onTap});

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1B8) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              color: selected ? AppTheme.navy : const Color(0xFF7A8AA0),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppTheme.navy : const Color(0xFF7A8AA0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
