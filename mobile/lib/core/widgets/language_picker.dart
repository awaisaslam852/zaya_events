import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/locale_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'zaya_fields.dart';

class LanguagePickerCard extends StatelessWidget {
  const LanguagePickerCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = context.watch<LocaleCubit>().state.languageCode;
    final picker = SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'en', label: Text(l10n.english), icon: const Icon(Icons.language)),
        ButtonSegment(value: 'ar', label: Text(l10n.arabic), icon: const Icon(Icons.translate)),
      ],
      selected: {code},
      onSelectionChanged: (value) => context.read<LocaleCubit>().setLocale(value.first),
    );
    if (compact) {
      return picker;
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
          const SizedBox(height: 12),
          picker,
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
    final code = context.watch<LocaleCubit>().state.languageCode;
    final color = light ? Colors.white : AppTheme.navy;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LangChip(
          label: 'EN',
          selected: code == 'en',
          color: color,
          onTap: () => context.read<LocaleCubit>().setLocale('en'),
        ),
        const SizedBox(width: 6),
        _LangChip(
          label: 'ع',
          selected: code == 'ar',
          color: color,
          onTap: () => context.read<LocaleCubit>().setLocale('ar'),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.label, required this.selected, required this.color, required this.onTap});

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.yellow : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1A1A1A) : color,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
