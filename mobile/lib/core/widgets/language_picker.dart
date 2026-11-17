import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/locale_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../i18n/app_languages.dart';
import '../theme/app_theme.dart';
import 'zaya_dialogs.dart';
import 'zaya_fields.dart';

Future<void> showAppLanguagePicker(BuildContext context) {
  final cubit = context.read<LocaleCubit>();
  return showZayaSheet<void>(
    context: context,
    child: BlocProvider.value(
      value: cubit,
      child: const _LanguagePickerSheet(),
    ),
  );
}

class LanguagePickerCard extends StatelessWidget {
  const LanguagePickerCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LocaleCubit>().current;
    final tile = ListTile(
      contentPadding: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 4),
      leading: const Icon(Icons.translate, color: AppTheme.navy),
      title: Text(language.nativeName, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(language.englishName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showAppLanguagePicker(context),
    );
    if (compact) {
      return tile;
    }
    return ZayaSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, color: AppTheme.navy),
              const SizedBox(width: 8),
              Text(l10n.appLanguage, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.languageHint, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 4),
          tile,
        ],
      ),
    );
  }
}

class LanguageHeaderActions extends StatelessWidget {
  const LanguageHeaderActions({super.key, this.light = true});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().current;
    final color = light ? Colors.white : AppTheme.navy;
    return InkWell(
      onTap: () => showAppLanguagePicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 132),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: light ? Colors.white.withValues(alpha: 0.12) : AppTheme.yellow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate, size: 16, color: light ? Colors.white : const Color(0xFF1A1A1A)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                language.nativeName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: light ? color : const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet();

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<AppLanguage> _filtered(AppLanguage current) {
    final query = _query.text.trim().toLowerCase();
    final matches = query.isEmpty
        ? List<AppLanguage>.from(AppLanguages.all)
        : AppLanguages.all.where((language) {
            return language.englishName.toLowerCase().contains(query) ||
                language.nativeName.toLowerCase().contains(query) ||
                language.tag.toLowerCase().contains(query);
          }).toList();
    matches.sort((a, b) {
      if (a.tag == current.tag) {
        return -1;
      }
      if (b.tag == current.tag) {
        return 1;
      }
      return a.englishName.compareTo(b.englishName);
    });
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = context.watch<LocaleCubit>().current;
    final languages = _filtered(current);
    final height = MediaQuery.sizeOf(context).height * 0.86;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(color: const Color(0xFFD7E4F2), borderRadius: BorderRadius.circular(99)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.chooseLanguage,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.ink),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppTheme.navy),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              autofocus: false,
              decoration: InputDecoration(
                hintText: l10n.searchLanguages,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _query.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
          Expanded(
            child: languages.isEmpty
                ? Center(child: Text(l10n.empty))
                : ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final selected = language.tag == current.tag;
                      return ListTile(
                        selected: selected,
                        leading: CircleAvatar(
                          backgroundColor: selected ? AppTheme.yellow : AppTheme.wash,
                          child: Text(
                            language.locale.languageCode.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selected ? const Color(0xFF1A1A1A) : AppTheme.navy,
                            ),
                          ),
                        ),
                        title: Text(language.nativeName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(language.englishName),
                        trailing: selected ? const Icon(Icons.check_circle, color: AppTheme.navy) : null,
                        onTap: () async {
                          await context.read<LocaleCubit>().setLocale(language.tag);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
