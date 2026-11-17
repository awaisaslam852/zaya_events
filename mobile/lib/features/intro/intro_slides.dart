import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class IntroSlide {
  const IntroSlide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    required this.satellites,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final List<IconData> satellites;
}

List<IntroSlide> introSlides(AppLocalizations l10n) {
  return [
    IntroSlide(
      eyebrow: l10n.appTitle,
      title: l10n.introWelcomeTitle,
      body: l10n.introWelcomeBody,
      icon: Icons.auto_awesome,
      accent: const Color(0xFFFEBB02),
      satellites: const [
        Icons.apartment_outlined,
        Icons.favorite_outline,
        Icons.celebration_outlined,
      ],
    ),
    IntroSlide(
      eyebrow: l10n.venues,
      title: l10n.introDiscoverTitle,
      body: l10n.introDiscoverBody,
      icon: Icons.apartment_outlined,
      accent: const Color(0xFF7EC8FF),
      satellites: const [
        Icons.storefront_outlined,
        Icons.directions_car_outlined,
        Icons.hotel_outlined,
      ],
    ),
    IntroSlide(
      eyebrow: l10n.paySecurely,
      title: l10n.introPayTitle,
      body: l10n.introPayBody,
      icon: Icons.credit_card,
      accent: const Color(0xFF4ADE80),
      satellites: const [
        Icons.lock_outline,
        Icons.receipt_long_outlined,
        Icons.account_balance_wallet_outlined,
      ],
    ),
    IntroSlide(
      eyebrow: l10n.chat,
      title: l10n.introConnectTitle,
      body: l10n.introConnectBody,
      icon: Icons.forum_outlined,
      accent: const Color(0xFFFFD36E),
      satellites: const [
        Icons.videocam_outlined,
        Icons.calendar_month_outlined,
        Icons.auto_awesome,
      ],
    ),
  ];
}
