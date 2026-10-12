import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/cubit/locale_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final busy = state.maybeWhen(busy: () => true, orElse: () => false);
          final message = state.maybeWhen(unauthenticated: (m) => m, orElse: () => null);
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              ScreenHeader(
                eyebrow: 'ZAYA',
                title: l10n.register,
                subtitle: l10n.tagline,
                showBack: true,
                trailing: const LanguageHeaderActions(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  children: [
                    const LanguagePickerCard(),
                    const SizedBox(height: 12),
                    ZayaSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: busy ? null : _pickPhoto,
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: AppTheme.wash,
                                backgroundImage: _avatar == null ? null : FileImage(File(_avatar!.path)),
                                child: _avatar == null
                                    ? const Icon(Icons.add_a_photo_outlined, color: AppTheme.navy, size: 32)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(onPressed: busy ? null : _pickPhoto, child: Text(l10n.changePhoto)),
                          const SizedBox(height: 8),
                          SegmentedButton<String>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: 'customer', icon: Icon(Icons.celebration_outlined)),
                              ButtonSegment(value: 'vendor', icon: Icon(Icons.storefront_outlined)),
                            ],
                            selected: {_role},
                            onSelectionChanged: (value) => setState(() => _role = value.first),
                          ),
                          const SizedBox(height: 8),
                          Text(_role == 'vendor' ? l10n.roleVendor : l10n.roleCustomer, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ZayaTextField(controller: _first, label: l10n.firstName, icon: Icons.badge_outlined),
                          const SizedBox(height: 12),
                          ZayaTextField(controller: _last, label: l10n.lastName, icon: Icons.person_outline),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                          ZayaTextField(
                            controller: _phone,
                            label: l10n.phone,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.country,
                              prefixIcon: const Icon(Icons.public_outlined),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _country,
                                items: [
                                  for (final country in kCountries)
                                    DropdownMenuItem(value: country.code, child: Text('${country.name} (${country.code})')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _country = value);
                                  }
                                },
                              ),
                            ),
                          ),
                          if (_role == 'vendor') ...[
                            const SizedBox(height: 12),
                            ZayaTextField(controller: _biz, label: l10n.businessName, icon: Icons.storefront_outlined),
                            const SizedBox(height: 12),
                            ZayaTextField(controller: _city, label: l10n.city, icon: Icons.location_city_outlined),
                            const SizedBox(height: 12),
                            ZayaTextField(controller: _legal, label: l10n.legalName, icon: Icons.apartment_outlined),
                          ],
                          if (message != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ),
                          const SizedBox(height: 20),
                          ZayaPrimaryButton(
                            label: l10n.register,
                            busy: busy,
                            icon: Icons.person_add_alt_1_outlined,
                            onPressed: () {
                              final name = _biz.text.trim();
                              context.read<AuthBloc>().add(
                                    AuthEvent.register(
                                      email: _email.text.trim(),
                                      password: _password.text,
                                      firstName: _first.text.trim(),
                                      lastName: _last.text.trim(),
                                      role: _role,
                                      country: _country,
                                      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                                      locale: context.read<LocaleCubit>().state.languageCode,
                                      businessNameEn: name,
                                      businessNameAr: name,
                                      city: _city.text.trim().isEmpty ? null : _city.text.trim(),
                                      legalName: _legal.text.trim().isEmpty ? null : _legal.text.trim(),
                                      avatarPath: _avatar?.path,
                                      avatarName: _avatar?.name,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
