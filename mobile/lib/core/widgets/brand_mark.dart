import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 44, this.onLongPress});

  final double size;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/branding/mark.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: 'Zaya Events',
      ),
    );
    if (onLongPress == null) {
      return image;
    }
    return GestureDetector(onLongPress: onLongPress, child: image);
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.height = 56});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'Zaya Events',
    );
  }
}
