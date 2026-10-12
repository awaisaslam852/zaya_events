import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/locale_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    context.watch<LocaleCubit>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const LanguagePickerCard(),
          const SizedBox(height: 12),
          ZayaSectionCard(
            child: FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final info = snap.data;
                return Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFDCEBFA),
                      child: Icon(Icons.info_outline, color: AppTheme.navy),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.version, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(info == null ? '—' : '${info.version}+${info.buildNumber}'),
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
    );
  }
}
