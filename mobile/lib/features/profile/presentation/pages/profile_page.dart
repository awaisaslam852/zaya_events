import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/profile_menu_tile.dart';
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
              final initial = user.fullName.trim().isEmpty
                  ? '?'
                  : user.fullName.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase();
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppTheme.navy,
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(l10n.profile, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                              const Spacer(),
                              const LanguageHeaderActions(),
                              IconButton(
                                onPressed: () => context.push('/settings'),
                                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppTheme.yellow,
                            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF1A1A1A))),
                          ),
                          const SizedBox(height: 12),
                          Text(user.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role,
                              style: const TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w700, fontSize: 12),
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
                        const LanguagePickerCard(),
                        const SizedBox(height: 12),
                        ProfileMenuTile(
                          icon: Icons.person_outline,
                          title: l10n.editProfile,
                          subtitle: l10n.account,
                          onTap: () => context.push('/profile/edit'),
                        ),
                        const SizedBox(height: 10),
                        ProfileMenuTile(
                          icon: Icons.notifications_none,
                          title: l10n.notifications,
                          onTap: () => context.push('/notifications'),
                        ),
                        const SizedBox(height: 10),
                        ProfileMenuTile(
                          icon: Icons.call_outlined,
                          title: l10n.callHistory,
                          onTap: () => context.push('/calls/history'),
                        ),
                        const SizedBox(height: 10),
                        ProfileMenuTile(
                          icon: Icons.settings_outlined,
                          title: l10n.settings,
                          onTap: () => context.push('/settings'),
                        ),
                        const SizedBox(height: 10),
                        ProfileMenuTile(
                          icon: Icons.logout,
                          title: l10n.logout,
                          danger: true,
                          onTap: () => context.read<AuthBloc>().add(const AuthEvent.logout()),
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
