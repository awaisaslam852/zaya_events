import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class AdminRedirectPage extends StatelessWidget {
  const AdminRedirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.adminRedirect, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => launchUrl(
                Uri.parse(sl<AppConfig>().adminWebUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l10n.openAdmin),
            ),
            TextButton(
              onPressed: () => sl<AuthBloc>().add(const AuthEvent.logout()),
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}
