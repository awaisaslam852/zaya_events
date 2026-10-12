import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/usecases/auth_usecases.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(eyebrow: 'ZAYA', title: l10n.forgotPassword, showBack: true),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ZayaSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ZayaTextField(
                    controller: _email,
                    label: l10n.email,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  ZayaPrimaryButton(
                    label: l10n.sendResetLink,
                    icon: Icons.mark_email_read_outlined,
                    onPressed: () async {
                      await sl<ForgotPasswordUseCase>()(_email.text.trim());
                      setState(() => _sent = true);
                    },
                  ),
                  if (_sent)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(l10n.saveSuccess, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.token});
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(eyebrow: 'ZAYA', title: l10n.resetPassword, showBack: true),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ZayaSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ZayaTextField(
                    controller: _password,
                    label: l10n.newPassword,
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ZayaPrimaryButton(
                    label: l10n.save,
                    onPressed: () async {
                      await sl<ResetPasswordUseCase>()(token: widget.token, password: _password.text);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
