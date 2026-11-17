import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../constants/countries.dart';
import '../theme/app_theme.dart';
import 'zaya_dialogs.dart';

Future<String?> showCountryPicker(
  BuildContext context, {
  String? selectedCode,
}) {
  return showZayaSheet<String>(
    context: context,
    child: _CountryPickerSheet(selectedCode: selectedCode),
  );
}

class CountryPickerField extends StatelessWidget {
  const CountryPickerField({
    super.key,
    required this.selectedCode,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String selectedCode;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final selected = countryByCode(selectedCode);
    final label = selected == null
        ? l10n.chooseCountry
        : '${selected.flagEmoji}  ${selected.label(languageCode)}';

    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await showCountryPicker(context, selectedCode: selectedCode);
              if (picked != null) {
                onChanged(picked);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          labelText: l10n.country,
          prefixIcon: const Icon(Icons.public_outlined, color: AppTheme.navy),
          suffixIcon: const Icon(Icons.search, color: AppTheme.navy),
          errorText: errorText,
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected == null ? AppTheme.muted : AppTheme.ink,
          ),
        ),
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({this.selectedCode});

  final String? selectedCode;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final countries = filterCountries(_query.text, languageCode: languageCode);
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
                    l10n.chooseCountry,
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
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchCountries,
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
            child: countries.isEmpty
                ? Center(child: Text(l10n.empty))
                : ListView.separated(
                    itemCount: countries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final country = countries[index];
                      final selected = country.code == widget.selectedCode;
                      return ListTile(
                        selected: selected,
                        leading: CircleAvatar(
                          backgroundColor: selected ? AppTheme.yellow : AppTheme.wash,
                          child: Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
                        ),
                        title: Text(
                          country.localizedName(languageCode),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('${country.code} · ${country.name}'),
                        trailing: selected ? const Icon(Icons.check_circle, color: AppTheme.navy) : null,
                        onTap: () => Navigator.of(context).pop(country.code),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
