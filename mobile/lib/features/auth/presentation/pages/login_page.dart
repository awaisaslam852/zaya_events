import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.busy,
    this.message,
    required this.onSubmit,
    this.onRegister,
    this.onForgotPassword,
    this.apiBaseUrl,
  });

  final bool busy;
  final String? message;
  final void Function(String email, String password) onSubmit;
  final VoidCallback? onRegister;
  final VoidCallback? onForgotPassword;
  final String? apiBaseUrl;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final TextEditingController _apiUrl;
  bool _showApi = false;

  @override
  void initState() {
    super.initState();
    _apiUrl = TextEditingController(text: widget.apiBaseUrl ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _apiUrl.dispose();
    super.dispose();
  }

  Future<void> _applyApiUrl() async {
    var url = _apiUrl.text.trim();
    if (url.isEmpty) {
      return;
    }
    url = await AppConfig.rewriteForDevice(url);
    sl<AppConfig>().apiBaseUrl = url;
    sl<ApiClient>().setBaseUrl(url);
    await sl<SharedPreferences>().setString(AppConfig.prefsOverrideKey, url);
    _apiUrl.text = url;
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API set to $url')));
    }
  }

  void _fill(String email, String password) {
    setState(() {
      _email.text = email;
      _password.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: AppTheme.navy,
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onLongPress: () => setState(() => _showApi = !_showApi),
                    child: const Text(
                      'ZAYA',
                      style: TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, letterSpacing: 3),
                    ),
                  ),
                  const Spacer(),
                  const LanguageHeaderActions(),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.welcomeBack, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l10n.tagline, style: const TextStyle(color: Colors.white70, height: 1.35)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showApi) ...[
                Text(
                  defaultTargetPlatform == TargetPlatform.android && !kIsWeb
                      ? 'Android cannot use 127.0.0.1 (that is the phone). Emulator: 10.0.2.2:4000. Real phone: your Mac Wi-Fi IP, same network.'
                      : l10n.apiHost,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiUrl,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.apiHost,
                    hintText: 'http://10.0.2.2:4000/api/v1',
                    prefixIcon: const Icon(Icons.cloud_outlined),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: _applyApiUrl, child: Text(l10n.useThisApi)),
                ),
                const SizedBox(height: 8),
              ],
              ZayaTextField(
                controller: _email,
                label: l10n.email,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              ZayaTextField(
                controller: _password,
                label: l10n.password,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              if (widget.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(widget.message!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 20),
              ZayaPrimaryButton(
                label: l10n.login,
                busy: widget.busy,
                icon: Icons.login,
                onPressed: () => widget.onSubmit(_email.text.trim(), _password.text),
              ),
              TextButton(onPressed: widget.onRegister, child: Text(l10n.register)),
              TextButton(onPressed: widget.onForgotPassword, child: Text(l10n.forgotPassword)),
              const SizedBox(height: 16),
              Text(l10n.tryDemo, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.person_outline, size: 18, color: AppTheme.navy),
                    label: Text(l10n.demoCustomer),
                    onPressed: widget.busy ? null : () => _fill('guest@zayaevents.com', 'ChangeMeGuest!123'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.storefront_outlined, size: 18, color: AppTheme.navy),
                    label: Text(l10n.demoVendor),
                    onPressed: widget.busy ? null : () => _fill('palms@vendors.zayaevents.com', 'ChangeMeVendor!123'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {},
        builder: (context, state) {
          final restoring = state.maybeWhen(unknown: () => true, orElse: () => false);
          if (restoring) {
            return const Center(child: CircularProgressIndicator());
          }
          return LoginForm(
            busy: state.maybeWhen(busy: () => true, orElse: () => false),
            message: state.maybeWhen(unauthenticated: (m) => m, orElse: () => null),
            apiBaseUrl: sl<AppConfig>().apiBaseUrl,
            onSubmit: (email, password) =>
                context.read<AuthBloc>().add(AuthEvent.login(email: email, password: password)),
            onRegister: () => context.push('/register'),
            onForgotPassword: () => context.push('/forgot-password'),
          );
        },
      ),
    );
  }
}
