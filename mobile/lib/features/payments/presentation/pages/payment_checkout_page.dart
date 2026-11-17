import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/session_role.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/customer_hub.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/zaya_fields.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/domain/usecases/bookings_usecases.dart';
import '../../payment_checkout_args.dart';
import '../../stripe_payment_sheet.dart';

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({super.key, required this.args});

  final PaymentCheckoutArgs args;

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  bool _busy = false;
  bool _success = false;
  String? _error;

  String _kindLabel(AppLocalizations l10n) {
    return widget.args.kind.toUpperCase() == 'BALANCE' ? l10n.payBalance : l10n.payDeposit;
  }

  Future<void> _pay() async {
    if (_busy || _success || isVendorSession(context)) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await presentStripePaymentSheet(
        publishableKey: widget.args.publishableKey,
        clientSecret: widget.args.clientSecret,
      );
      var confirmed = await sl<ConfirmBookingPayment>()(widget.args.paymentId);
      if (confirmed.isLeft()) {
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        confirmed = await sl<ConfirmBookingPayment>()(widget.args.paymentId);
      }
      if (!mounted) {
        return;
      }
      confirmed.fold(
        (failure) => setState(() {
          _busy = false;
          _error = failure.message;
        }),
        (_) {
          setState(() {
            _busy = false;
            _success = true;
          });
          Future<void>.delayed(const Duration(milliseconds: 900), () {
            if (mounted) {
              context.pop(true);
            }
          });
        },
      );
    } on PaymentSheetCanceled {
      if (mounted) {
        setState(() => _busy = false);
      }
    } on PaymentSheetFailed catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final amount = formatMoney(widget.args.amount, widget.args.currency);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: Column(
        children: [
          ScreenHeader(
            showBack: true,
            eyebrow: l10n.checkout,
            title: _success ? l10n.paymentSuccess : l10n.paySecurely,
            subtitle: widget.args.title ?? _kindLabel(l10n),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _kindLabel(l10n).toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.navy,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        amount,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.args.title != null) ...[
                        const SizedBox(height: 8),
                        Text(widget.args.title!, style: const TextStyle(color: AppTheme.muted, height: 1.35)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _success ? Icons.check_circle : Icons.lock_outline,
                        color: _success ? const Color(0xFF0F7B3A) : AppTheme.navy,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _success ? l10n.paymentSuccess : l10n.cardCheckoutHint,
                          style: const TextStyle(color: AppTheme.ink, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, height: 1.35)),
                ],
              ],
            ),
          ),
          if (!_success)
            Material(
              color: Colors.white,
              elevation: 12,
              shadowColor: AppTheme.navy.withValues(alpha: 0.12),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: ZayaPrimaryButton(
                    label: '${l10n.paySecurely} · $amount',
                    icon: Icons.credit_card,
                    busy: _busy,
                    onPressed: _pay,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
