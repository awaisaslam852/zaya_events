import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/zaya_dialogs.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';

Future<({int rating, String comment})?> showBookingReviewSheet(
  BuildContext context, {
  required bool isVendor,
}) {
  final l10n = AppLocalizations.of(context);
  return showZayaSheet<({int rating, String comment})>(
    context: context,
    child: ZayaSheetScaffold(
      title: isVendor ? l10n.rateGuest : l10n.rateVendor,
      subtitle: isVendor ? l10n.rateGuestHint : l10n.rateVendorHint,
      child: const _ReviewForm(),
    ),
  );
}

class _ReviewForm extends StatefulWidget {
  const _ReviewForm();

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _comment = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i <= _rating ? AppTheme.yellow : AppTheme.muted,
                    size: 36,
                  ),
                ),
            ],
          ),
          Text(
            l10n.starRating('$_rating'),
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy),
          ),
          const SizedBox(height: 12),
          ZayaTextField(
            controller: _comment,
            label: l10n.reviewComment,
            icon: Icons.notes_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          ZayaPrimaryButton(
            label: l10n.submitReview,
            icon: Icons.star_outline,
            onPressed: () => Navigator.pop(context, (rating: _rating, comment: _comment.text.trim())),
          ),
        ],
      ),
    );
  }
}

class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.rating, this.size = 18});
  final num rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final rounded = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rounded ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i <= rounded ? AppTheme.yellow : const Color(0xFFC5D4E5),
          ),
      ],
    );
  }
}
