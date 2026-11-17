import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/app_role.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/profile_menu_tile.dart';
import '../../../../core/widgets/zaya_avatar.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.maybeWhen(
            authenticated: (user) {
              final role = parseAppRole(user.role);
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00183D), Color(0xFF003580), Color(0xFF0B5BB5)],
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 8, 12, 28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.profile,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                              ),
                              const Spacer(),
                              const LanguageHeaderActions(),
                              IconButton(
                                onPressed: () => context.push('/settings'),
                                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          ZayaAvatar(
                            url: profileImageUrl(user),
                            initials: profileInitials(user),
                            radius: 44,
                            backgroundColor: AppTheme.yellow,
                            foregroundColor: const Color(0xFF1A1A1A),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.fullName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role,
                              style: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverList.list(
                      children: [
                        ProfileSectionTitle(l10n.account),
                        const LanguagePickerCard(),
                        const SizedBox(height: 8),
                        ProfileMenuTile(
                          icon: Icons.person_outline,
                          title: l10n.editProfile,
                          subtitle: l10n.account,
                          onTap: () => context.push('/profile/edit'),
                        ),
                        if (role == AppRole.customer) ...[
                          ProfileSectionTitle(l10n.planning),
                          ProfileMenuTile(
                            icon: Icons.celebration_outlined,
                            title: l10n.myEvents,
                            subtitle: l10n.eventsSubtitle,
                            onTap: () => context.push('/customer/events'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.shopping_bag_outlined,
                            title: l10n.cart,
                            subtitle: l10n.cartSubtitle,
                            onTap: () => context.push('/customer/cart'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.meeting_room_outlined,
                            title: l10n.venueVisits,
                            subtitle: l10n.visitsSubtitle,
                            onTap: () => context.push('/customer/visits'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.auto_awesome,
                            title: l10n.aiPlanner,
                            subtitle: l10n.aiSubtitle,
                            onTap: () => context.push('/customer/ai'),
                          ),
                          ProfileSectionTitle(l10n.paymentHistory),
                          ProfileMenuTile(
                            icon: Icons.payments_outlined,
                            title: l10n.paymentHistory,
                            subtitle: l10n.paymentsSubtitle,
                            onTap: () => context.push('/customer/payments'),
                          ),
                        ],
                        if (role == AppRole.vendor) ...[
                          ProfileSectionTitle(l10n.partnerHub),
                          ProfileMenuTile(
                            icon: Icons.storefront_outlined,
                            title: l10n.vendorProfile,
                            onTap: () => context.push('/vendor/business'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.payments_outlined,
                            title: l10n.earnings,
                            subtitle: l10n.paymentHistory,
                            onTap: () => context.push('/vendor/earnings'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.receipt_long_outlined,
                            title: l10n.bookingHistory,
                            onTap: () => context.push('/vendor/bookings'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.calendar_month_outlined,
                            title: l10n.calendar,
                            subtitle: l10n.availability,
                            onTap: () => context.push('/vendor/calendar'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.meeting_room_outlined,
                            title: l10n.venueVisits,
                            onTap: () => context.push('/vendor/visits'),
                          ),
                          ProfileMenuTile(
                            icon: Icons.star_outline,
                            title: l10n.reviews,
                            onTap: () => context.push('/vendor/reviews'),
                          ),
                        ],
                        ProfileSectionTitle(l10n.support),
                        ProfileMenuTile(
                          icon: Icons.notifications_none,
                          title: l10n.notifications,
                          subtitle: l10n.notificationsSubtitle,
                          onTap: () => context.push('/notifications'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.call_outlined,
                          title: l10n.callHistory,
                          subtitle: l10n.callsSubtitle,
                          onTap: () => context.push('/calls/history'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.settings_outlined,
                          title: l10n.settings,
                          subtitle: l10n.settingsSubtitle,
                          onTap: () => context.push('/settings'),
                        ),
                        ProfileMenuTile(
                          icon: Icons.logout,
                          title: l10n.logout,
                          danger: true,
                          onTap: () async {
                            final ok = await showZayaLogoutConfirm(context);
                            if (!ok || !context.mounted) {
                              return;
                            }
                            context.read<AuthBloc>().add(const AuthEvent.logout());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
