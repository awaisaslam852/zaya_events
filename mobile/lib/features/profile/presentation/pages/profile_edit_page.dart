import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ZayaSectionCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.navy,
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () async {
                          final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (file == null) {
                            return;
                          }
                          setState(() => _busy = true);
                          final uploaded = await sl<UploadService>().upload(
                            filePath: file.path,
                            filename: file.name,
                            folder: 'avatars',
                          );
                          await uploaded.fold((_) async {}, (result) async {
                            await sl<UpdateProfileUseCase>()({'avatarKey': result.key});
                          });
                          if (!mounted) {
                            return;
                          }
                          context.read<AuthBloc>().add(const AuthEvent.userUpdated());
                          setState(() => _busy = false);
                        },
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(l10n.changePhoto),
                ),
                const SizedBox(height: 16),
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
                ZayaPrimaryButton(
                  label: l10n.save,
                  busy: _busy,
                  onPressed: () async {
                    setState(() => _busy = true);
                    final result = await sl<UpdateProfileUseCase>()({
                      'firstName': _first.text.trim(),
                      'lastName': _last.text.trim(),
                      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                    });
                    if (!context.mounted) {
                      return;
                    }
                    setState(() => _busy = false);
                    result.fold(
                      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
                      (_) {
                        context.read<AuthBloc>().add(const AuthEvent.userUpdated());
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
