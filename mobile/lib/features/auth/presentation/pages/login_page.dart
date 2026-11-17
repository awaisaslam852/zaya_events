import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../register_form_errors.dart';

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
  bool _hidePassword = true;
  LoginFormErrors _errors = const LoginFormErrors();
  String? _shownMessage;

  @override
  void initState() {
    super.initState();
    _apiUrl = TextEditingController(text: widget.apiBaseUrl ?? '');
  }

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final message = widget.message;
    if (message != null && message != oldWidget.message && message != _shownMessage) {
      _shownMessage = message;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errors = LoginFormErrors(
          email: message.toLowerCase().contains('email') ? l10n.invalidEmail : _errors.email,
          password: message.toLowerCase().contains('password') || message.toLowerCase().contains('credential')
              ? message
              : _errors.password,
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        showZayaAlert(
          context,
          title: l10n.checkYourDetails,
          message: message == 'Validation failed' ? l10n.fixHighlightedFields : message,
        );
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00183D), Color(0xFF003580), Color(0xFF0B5BB5)],
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 12, 16, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BrandMark(
                    size: 48,
                    onLongPress: () => setState(() => _showApi = !_showApi),
                  ),
                  const Spacer(),
                  const LanguageHeaderActions(),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                l10n.appTitle,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15),
              ),
              const SizedBox(height: 8),
              Text(l10n.welcomeBack, style: const TextStyle(color: AppTheme.yellow, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              Text(l10n.tagline, style: const TextStyle(color: Colors.white70, height: 1.4)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.line),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_showApi) ...[
                  Text(
                    defaultTargetPlatform == TargetPlatform.android && !kIsWeb
                        ? 'Live API is https://zaya-events.com/api/v1. For local debug use 10.0.2.2:4000 (emulator) or your Mac Wi-Fi IP (phone).'
                        : l10n.apiHost,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiUrl,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l10n.apiHost,
                      hintText: 'https://zaya-events.com/api/v1',
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
                  errorText: _errors.email,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) {
                    if (_errors.email != null) {
                      setState(() => _errors = LoginFormErrors(password: _errors.password));
                    }
                  },
                ),
                const SizedBox(height: 12),
                ZayaTextField(
                  controller: _password,
                  label: l10n.password,
                  icon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  errorText: _errors.password,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onChanged: (_) {
                    if (_errors.password != null) {
                      setState(() => _errors = LoginFormErrors(email: _errors.email));
                    }
                  },
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppTheme.navy),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onForgotPassword,
                    child: Text(l10n.forgotPassword, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                ZayaPrimaryButton(
                  label: l10n.login,
                  busy: widget.busy,
                  icon: Icons.login,
                  onPressed: () async {
                    final errors = validateLoginForm(
                      l10n: l10n,
                      email: _email.text,
                      password: _password.text,
                    );
                    if (errors.hasErrors) {
                      setState(() => _errors = errors);
                      await showZayaAlert(
                        context,
                        title: l10n.checkYourDetails,
                        message: errors.popupMessage(l10n),
                      );
                      return;
                    }
                    widget.onSubmit(_email.text.trim(), _password.text);
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: widget.onRegister,
                  child: Text(l10n.register),
                ),
              ],
            ),
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
      backgroundColor: AppTheme.canvas,
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
