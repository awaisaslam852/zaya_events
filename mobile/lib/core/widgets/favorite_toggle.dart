import 'package:flutter/material.dart';
import '../di/injection.dart';
import '../network/api_client.dart';
import '../../l10n/app_localizations.dart';

class FavoriteToggleButton extends StatefulWidget {
  const FavoriteToggleButton({super.key, required this.resourceType, required this.resourceId});

  final String resourceType;
  final String resourceId;

  @override
  State<FavoriteToggleButton> createState() => _FavoriteToggleButtonState();
}

class _FavoriteToggleButtonState extends State<FavoriteToggleButton> {
  bool _saved = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await sl<ApiClient>().get<List<Map<String, dynamic>>>(
      '/favorites',
      query: {'resourceType': widget.resourceType, 'pageSize': 100},
      parse: (data) {
        final map = Map<String, dynamic>.from(data as Map);
        return (map['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
    if (!mounted) {
      return;
    }
    result.fold((_) {}, (items) {
      final match = items.any((item) {
        final id = item['resourceId']?.toString();
        final ref = item['providerRef']?.toString();
        return id == widget.resourceId || ref == widget.resourceId;
      });
      setState(() => _saved = match);
    });
  }

  Future<void> _toggle() async {
    setState(() => _busy = true);
    final body = {'resourceType': widget.resourceType, 'resourceId': widget.resourceId};
    final result = _saved
        ? await sl<ApiClient>().delete('/favorites', data: body, parse: (_) => true)
        : await sl<ApiClient>().post('/favorites', data: body, parse: (_) => true);
    if (!mounted) {
      return;
    }
    result.fold(
      (failure) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => setState(() {
        _saved = !_saved;
        _busy = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: _saved ? l10n.removeFavorite : l10n.addFavorite,
      onPressed: _busy ? null : _toggle,
      icon: Icon(_saved ? Icons.favorite : Icons.favorite_border, color: _saved ? Colors.redAccent : null),
    );
  }
}
