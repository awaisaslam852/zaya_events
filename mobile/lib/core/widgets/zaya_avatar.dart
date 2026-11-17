import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../theme/app_theme.dart';
import 'property_card.dart';

String? profileImageUrl(UserEntity user) {
  final candidates = <String?>[
    user.avatarKey,
    user.vendor?['logoKey']?.toString(),
    user.vendor?['coverKey']?.toString(),
    user.vendor?['logoUrl']?.toString(),
  ];
  for (final value in candidates) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      continue;
    }
    return resolveMediaUrl(text);
  }
  return null;
}

String profileInitials(UserEntity user) {
  final name = user.fullName.trim();
  if (name.isEmpty) {
    return '?';
  }
  return name.split(RegExp(r'\s+')).map((part) => part[0]).take(2).join().toUpperCase();
}

class ZayaAvatar extends StatelessWidget {
  const ZayaAvatar({
    super.key,
    required this.url,
    this.initials = '?',
    this.radius = 42,
    this.backgroundColor = AppTheme.navy,
    this.foregroundColor = Colors.white,
  });

  final String? url;
  final String initials;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.5,
        ),
      ),
    );
    final imageUrl = url?.trim() ?? '';
    if (imageUrl.isEmpty) {
      return fallback;
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
