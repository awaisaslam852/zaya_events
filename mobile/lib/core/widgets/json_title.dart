import 'package:flutter/material.dart';
import '../utils/localized.dart';

class JsonTitle extends StatelessWidget {
  const JsonTitle(this.value, {super.key, this.style});
  final dynamic value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Text(localized(value, locale), style: style);
  }
}
