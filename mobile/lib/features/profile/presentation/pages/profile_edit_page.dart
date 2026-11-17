import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_avatar.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../uploads/presentation/upload_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;
  String? _localPreview;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().state.maybeWhen(
          authenticated: (user) {
            _first.text = user.firstName;
            _last.text = user.lastName;
            _phone.text = user.phone ?? '';
          },
          orElse: () {},
        );
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final result = await sl<UpdateProfileUseCase>()({
      'firstName': _first.text.trim(),
      'lastName': _last.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    });
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    result.fold(
      (failure) => showZayaSnack(context, failure.message, kind: ZayaSnackKind.error),
      (_) {
        context.read<AuthBloc>().add(const AuthEvent.userUpdated());
        Navigator.pop(context);
      },
    );
  }

  Future<void> _changePhoto() async {
    final l10n = AppLocalizations.of(context);
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) {
      return;
    }
    setState(() => _busy = true);
    final uploaded = await sl<UploadService>().upload(
      filePath: file.path,
      filename: file.name,
      folder: 'avatars',
    );
    if (!mounted) {
      return;
    }
    await uploaded.fold(
      (failure) async {
        showZayaSnack(context, failure.message, kind: ZayaSnackKind.error);
      },
      (result) async {
        final key = result.key.isNotEmpty ? result.key : result.url;
        if (key.isEmpty) {
          showZayaSnack(context, l10n.errorGeneric, kind: ZayaSnackKind.error);
          return;
        }
        final saved = await sl<UpdateProfileUseCase>()({'avatarKey': key});
        if (!mounted) {
          return;
        }
        saved.fold(
          (failure) => showZayaSnack(context, failure.message, kind: ZayaSnackKind.error),
          (_) {
            setState(() => _localPreview = resolveMediaUrl(result.url.isNotEmpty ? result.url : key));
            context.read<AuthBloc>().add(const AuthEvent.userUpdated());
          },
        );
      },
    );
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(showBack: true, eyebrow: l10n.account, title: l10n.editProfile, subtitle: l10n.account),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.line),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return state.maybeWhen(
                            authenticated: (user) => ZayaAvatar(
                              url: _localPreview ?? profileImageUrl(user),
                              initials: profileInitials(user),
                              radius: 48,
                            ),
                            orElse: () => ZayaAvatar(
                              url: _localPreview,
                              radius: 48,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _changePhoto,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.changePhoto),
                      ),
                      const SizedBox(height: 20),
                      ZayaTextField(controller: _first, label: l10n.firstName, icon: Icons.badge_outlined),
                      const SizedBox(height: 12),
                      ZayaTextField(controller: _last, label: l10n.lastName, icon: Icons.person_outline),
                      const SizedBox(height: 12),
                      ZayaTextField(
                        controller: _phone,
                        label: l10n.phone,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      ZayaPrimaryButton(label: l10n.save, busy: _busy, onPressed: _save),
                    ],
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
