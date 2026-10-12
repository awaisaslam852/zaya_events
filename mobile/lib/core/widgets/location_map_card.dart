import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class LocationMapCard extends StatelessWidget {
  const LocationMapCard({super.key, required this.latitude, required this.longitude, this.label});

  final double latitude;
  final double longitude;
  final String? label;

  static LocationMapCard? maybe(Map<String, dynamic> raw, {String? label}) {
    final lat = num.tryParse('${raw['latitude'] ?? ''}');
    final lng = num.tryParse('${raw['longitude'] ?? ''}');
    if (lat == null || lng == null) {
      return null;
    }
    return LocationMapCard(latitude: lat.toDouble(), longitude: lng.toDouble(), label: label);
  }

  Future<void> _open() async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _directions() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFDCEBFA),
              child: Icon(Icons.map_outlined, color: AppTheme.navy),
            ),
            title: Text(label ?? 'Location'),
            subtitle: Text('${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: _open,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _directions,
              icon: const Icon(Icons.directions),
              label: Text(AppLocalizations.of(context).getDirections),
            ),
          ),
        ],
      ),
    );
  }
}
