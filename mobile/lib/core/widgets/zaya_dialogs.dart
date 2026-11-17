import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

enum ZayaConfirmTone { danger, primary, neutral }

Future<bool> showZayaConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.error_outline,
  ZayaConfirmTone tone = ZayaConfirmTone.danger,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0xCC00183D),
    builder: (dialogContext) {
      return ZayaConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel ?? AppLocalizations.of(dialogContext).cancel,
        icon: icon,
        tone: tone,
      );
    },
  );
  return result == true;
}

Future<void> showZayaAlert(
  BuildContext context, {
  required String title,
  required String message,
  String? buttonLabel,
  IconData icon = Icons.error_outline,
  ZayaConfirmTone tone = ZayaConfirmTone.danger,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0xCC00183D),
    builder: (dialogContext) {
      return ZayaAlertDialog(
        title: title,
        message: message,
        buttonLabel: buttonLabel ?? AppLocalizations.of(dialogContext).gotIt,
        icon: icon,
        tone: tone,
      );
    },
  );
}

class ZayaAlertDialog extends StatelessWidget {
  const ZayaAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.icon,
    this.tone = ZayaConfirmTone.danger,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final IconData icon;
  final ZayaConfirmTone tone;

  Color get _accent {
    return switch (tone) {
      ZayaConfirmTone.danger => const Color(0xFFB42318),
      ZayaConfirmTone.primary => AppTheme.navy,
      ZayaConfirmTone.neutral => AppTheme.blue,
    };
  }

  Color get _wash {
    return switch (tone) {
      ZayaConfirmTone.danger => const Color(0xFFFFF1F1),
      ZayaConfirmTone.primary => AppTheme.wash,
      ZayaConfirmTone.neutral => const Color(0xFFF4F7FB),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: _wash, shape: BoxShape.circle),
              child: Icon(icon, color: _accent, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 22, height: 1.2),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.yellow,
                  foregroundColor: const Color(0xFF1A1A1A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ZayaConfirmDialog extends StatelessWidget {
  const ZayaConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    this.tone = ZayaConfirmTone.danger,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final ZayaConfirmTone tone;

  Color get _accent {
    return switch (tone) {
      ZayaConfirmTone.danger => const Color(0xFFB42318),
      ZayaConfirmTone.primary => AppTheme.navy,
      ZayaConfirmTone.neutral => AppTheme.blue,
    };
  }

  Color get _wash {
    return switch (tone) {
      ZayaConfirmTone.danger => const Color(0xFFFFF1F1),
      ZayaConfirmTone.primary => AppTheme.wash,
      ZayaConfirmTone.neutral => const Color(0xFFF4F7FB),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: _wash, shape: BoxShape.circle),
              child: Icon(icon, color: _accent, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w800, fontSize: 22, height: 1.2),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, fontSize: 15, height: 1.45),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.navy,
                      side: const BorderSide(color: Color(0xFFD7E4F2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(cancelLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: tone == ZayaConfirmTone.danger ? const Color(0xFFB42318) : AppTheme.yellow,
                      foregroundColor: tone == ZayaConfirmTone.danger ? Colors.white : const Color(0xFF1A1A1A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showZayaSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.white,
    barrierColor: const Color(0x9900183D),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheet) => child,
  );
}

class ZayaSheetScaffold extends StatelessWidget {
  const ZayaSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(color: const Color(0xFFD7E4F2), borderRadius: BorderRadius.circular(99)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.ink)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(subtitle!, style: const TextStyle(color: AppTheme.muted, height: 1.35)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppTheme.navy),
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

enum ZayaSnackKind { info, success, error }

SnackBar zayaSnackBar(
  String message, {
  ZayaSnackKind kind = ZayaSnackKind.info,
  SnackBarAction? action,
}) {
  final background = switch (kind) {
    ZayaSnackKind.success => const Color(0xFF0F7B3A),
    ZayaSnackKind.error => const Color(0xFFB42318),
    ZayaSnackKind.info => AppTheme.navy,
  };
  final icon = switch (kind) {
    ZayaSnackKind.success => Icons.check_circle_outline,
    ZayaSnackKind.error => Icons.error_outline,
    ZayaSnackKind.info => Icons.info_outline,
  };
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: background,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    action: action,
    content: Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

void showZayaSnack(
  BuildContext context,
  String message, {
  ZayaSnackKind kind = ZayaSnackKind.info,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(zayaSnackBar(message, kind: kind, action: action));
}

Future<bool> showZayaLogoutConfirm(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showZayaConfirm(
    context,
    title: l10n.logoutTitle,
    message: l10n.logoutMessage,
    confirmLabel: l10n.logout,
    cancelLabel: l10n.staySignedIn,
    icon: Icons.logout,
  );
}

Future<void> showZayaLightbox(BuildContext context, List<String> urls, int initialIndex) {
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0xE600183D),
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              ColoredBox(
                color: Colors.black,
                child: SizedBox(
                  height: MediaQuery.sizeOf(dialogContext).height * 0.78,
                  child: PageView.builder(
                    controller: PageController(initialPage: initialIndex),
                    itemCount: urls.length,
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: CachedNetworkImage(imageUrl: urls[index], fit: BoxFit.contain),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
