import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/locale_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleCubit>();
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(showBack: true, eyebrow: l10n.settings, title: l10n.settings, subtitle: l10n.settingsSubtitle),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const LanguagePickerCard(),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.wash,
                      child: Icon(Icons.auto_awesome, color: AppTheme.navy),
                    ),
                    title: Text(l10n.replayIntro, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(l10n.replayIntroHint, style: const TextStyle(color: AppTheme.muted)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.navy),
                    onTap: () => context.push('/intro'),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snap) {
                      final info = snap.data;
                      return Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppTheme.wash,
                            child: Icon(Icons.info_outline, color: AppTheme.navy),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.version, style: const TextStyle(fontWeight: FontWeight.w800)),
                                Text(
                                  info == null ? '—' : '${info.version}+${info.buildNumber}',
                                  style: const TextStyle(color: AppTheme.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
