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
    final l10n = AppLocalizations.of(context);
    final place = (label ?? '').trim().isEmpty ? l10n.location : label!.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _open,
                child: SizedBox(
                  height: 132,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD7E8F8), Color(0xFFB7D4F0), Color(0xFF9EC4EA)],
                          ),
                        ),
                      ),
                      CustomPaint(painter: _MapGridPainter()),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.navy,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: AppTheme.navy.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: const Icon(Icons.place, color: AppTheme.yellow),
                            ),
                            const SizedBox(height: 8),
                            Text(l10n.openInMaps, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w800, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.ink)),
                      const SizedBox(height: 2),
                      Text(l10n.location, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: _directions,
                  icon: const Icon(Icons.directions, size: 18),
                  label: Text(l10n.getDirections),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    const step = 22.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
