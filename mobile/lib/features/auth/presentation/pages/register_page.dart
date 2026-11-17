import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/country_picker.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/cubit/locale_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../register_form_errors.dart';

class RegisterDraft {
  const RegisterDraft({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.country,
    this.phone,
    this.businessNameEn,
    this.businessNameAr,
    this.city,
    this.legalName,
    this.avatarPath,
    this.avatarName,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String country;
  final String? phone;
  final String? businessNameEn;
  final String? businessNameAr;
  final String? city;
  final String? legalName;
  final String? avatarPath;
  final String? avatarName;
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterFormErrors? _remoteErrors;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, next) {
          final wasBusy = previous.maybeWhen(busy: () => true, orElse: () => false);
          final message = next.maybeWhen(unauthenticated: (m) => m, orElse: () => null);
          return wasBusy && message != null;
        },
        listener: (context, state) {
          final l10n = AppLocalizations.of(context);
          final failure = context.read<AuthBloc>().lastAuthFailure;
          final message = state.maybeWhen(unauthenticated: (m) => m, orElse: () => null);
          setState(() {
            _remoteErrors = registerErrorsFromApi(
              l10n: l10n,
              message: message,
              fieldErrors: failure?.fieldErrors,
              code: failure?.code,
            );
          });
          showZayaAlert(
            context,
            title: l10n.checkYourDetails,
            message: humanizeAuthMessage(
              l10n: l10n,
              message: message,
              fieldErrors: failure?.fieldErrors,
              code: failure?.code,
            ),
          );
        },
        builder: (context, state) {
          final busy = state.maybeWhen(busy: () => true, orElse: () => false);
          return RegisterForm(
            busy: busy,
            remoteErrors: _remoteErrors,
            onLogin: () => context.go('/login'),
            onSubmit: (draft) {
              setState(() => _remoteErrors = null);
              context.read<AuthBloc>().add(
                    AuthEvent.register(
                      email: draft.email,
                      password: draft.password,
                      firstName: draft.firstName,
                      lastName: draft.lastName,
                      role: draft.role,
                      country: draft.country,
                      phone: draft.phone,
                      locale: context.read<LocaleCubit>().current.catalogLocale,
                      businessNameEn: draft.businessNameEn,
                      businessNameAr: draft.businessNameAr,
                      city: draft.city,
                      legalName: draft.legalName,
                      avatarPath: draft.avatarPath,
                      avatarName: draft.avatarName,
                    ),
                  );
            },
          );
        },
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.busy,
    required this.onSubmit,
    this.onLogin,
    this.remoteErrors,
  });

  final bool busy;
  final ValueChanged<RegisterDraft> onSubmit;
  final VoidCallback? onLogin;
  final RegisterFormErrors? remoteErrors;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _biz = TextEditingController();
  final _city = TextEditingController();
  final _legal = TextEditingController();
  String _role = 'customer';
  String _country = 'AE';
  XFile? _avatar;
  bool _hidePassword = true;
  RegisterFormErrors _errors = const RegisterFormErrors();

  @override
  void initState() {
    super.initState();
    _errors = widget.remoteErrors ?? const RegisterFormErrors();
  }

  @override
  void didUpdateWidget(RegisterForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.remoteErrors;
    if (next != null && next != oldWidget.remoteErrors) {
      _errors = next;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _biz.dispose();
    _city.dispose();
    _legal.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _avatar = file);
    }
  }

  void _clear(String field) {
    if (!_errors.hasErrors) {
      return;
    }
    setState(() => _errors = _errors.clear(field));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final errors = validateRegisterForm(
      l10n: l10n,
      firstName: _first.text,
      lastName: _last.text,
      email: _email.text,
      password: _password.text,
      phone: _phone.text,
      country: _country,
      role: _role,
      businessName: _biz.text,
      city: _city.text,
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
    final name = _biz.text.trim();
    widget.onSubmit(
      RegisterDraft(
        email: _email.text.trim(),
        password: _password.text,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        role: _role,
        country: _country,
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        businessNameEn: name,
        businessNameAr: name,
        city: _city.text.trim().isEmpty ? null : _city.text.trim(),
        legalName: _legal.text.trim().isEmpty ? null : _legal.text.trim(),
        avatarPath: _avatar?.path,
        avatarName: _avatar?.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ScreenHeader(
          eyebrow: 'ZAYA',
          title: l10n.register,
          showBack: true,
          compact: true,
          trailing: const LanguageHeaderActions(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.line),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.busy ? null : _pickPhoto,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.wash,
                        backgroundImage: _avatar == null ? null : FileImage(File(_avatar!.path)),
                        child: _avatar == null
                            ? const Icon(Icons.add_a_photo_outlined, color: AppTheme.navy, size: 22)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: widget.busy ? null : _pickPhoto,
                      child: Text(l10n.changePhoto),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        selected: _role == 'customer',
                        icon: Icons.celebration_outlined,
                        label: l10n.roleCustomer,
                        onTap: () => setState(() => _role = 'customer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleCard(
                        selected: _role == 'vendor',
                        icon: Icons.storefront_outlined,
                        label: l10n.roleVendor,
                        onTap: () => setState(() => _role = 'vendor'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ZayaTextField(
                  controller: _first,
                  label: l10n.firstName,
                  icon: Icons.badge_outlined,
                  errorText: _errors.firstName,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  onChanged: (_) => _clear('firstName'),
                ),
                const SizedBox(height: 8),
                ZayaTextField(
                  controller: _last,
                  label: l10n.lastName,
                  icon: Icons.person_outline,
                  errorText: _errors.lastName,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  onChanged: (_) => _clear('lastName'),
                ),
                const SizedBox(height: 8),
                ZayaTextField(
                  controller: _email,
                  label: l10n.email,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _errors.email,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) => _clear('email'),
                ),
                const SizedBox(height: 8),
                ZayaTextField(
                  controller: _password,
                  label: l10n.password,
                  icon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  errorText: _errors.password,
                  helperText: l10n.passwordHint,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: (_) => _clear('password'),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.navy,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ZayaTextField(
                  controller: _phone,
                  label: l10n.phone,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  errorText: _errors.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onChanged: (_) => _clear('phone'),
                ),
                const SizedBox(height: 8),
                CountryPickerField(
                  selectedCode: _country,
                  enabled: !widget.busy,
                  errorText: _errors.country,
                  onChanged: (value) => setState(() {
                    _country = value;
                    _errors = _errors.clear('country');
                  }),
                ),
                if (_role == 'vendor') ...[
                  const SizedBox(height: 16),
                  Text(l10n.vendorProfile, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 12),
                  ZayaTextField(
                    controller: _biz,
                    label: l10n.businessName,
                    icon: Icons.storefront_outlined,
                    errorText: _errors.businessName,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _clear('businessName'),
                  ),
                  const SizedBox(height: 12),
                  ZayaTextField(
                    controller: _city,
                    label: l10n.city,
                    icon: Icons.location_city_outlined,
                    errorText: _errors.city,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _clear('city'),
                  ),
                  const SizedBox(height: 12),
                  ZayaTextField(
                    controller: _legal,
                    label: l10n.legalName,
                    icon: Icons.apartment_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                ],
                const SizedBox(height: 12),
                ZayaPrimaryButton(
                  label: l10n.register,
                  busy: widget.busy,
                  icon: Icons.person_add_alt_1_outlined,
                  onPressed: _submit,
                ),
                TextButton(
                  onPressed: widget.onLogin,
                  child: Text(l10n.login, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF8E6) : AppTheme.canvas,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? AppTheme.yellow : AppTheme.line, width: selected ? 2 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Column(
              children: [
                Icon(icon, color: AppTheme.navy, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: selected ? AppTheme.navy : AppTheme.ink,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
