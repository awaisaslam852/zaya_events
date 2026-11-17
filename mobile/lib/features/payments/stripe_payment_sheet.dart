import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentSheetCanceled implements Exception {}

class PaymentSheetFailed implements Exception {
  PaymentSheetFailed(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Native Stripe PaymentSheet for cards. Never opens a browser or Checkout URL.
Future<void> presentStripePaymentSheet({
  required String publishableKey,
  required String clientSecret,
  String merchantDisplayName = 'Zaya Events',
}) async {
  if (kIsWeb) {
    throw PaymentSheetFailed('Card checkout is available in the iOS and Android app.');
  }
  Stripe.publishableKey = publishableKey;
  Stripe.urlScheme = 'zayaevents';
  await Stripe.instance.applySettings();
  await Stripe.instance.initPaymentSheet(
    paymentSheetParameters: SetupPaymentSheetParameters(
      merchantDisplayName: merchantDisplayName,
      paymentIntentClientSecret: clientSecret,
      style: ThemeMode.light,
      returnURL: 'zayaevents://stripe-redirect',
      allowsDelayedPaymentMethods: false,
      appearance: const PaymentSheetAppearance(
        colors: PaymentSheetAppearanceColors(
          primary: Color(0xFF003580),
          primaryText: Color(0xFF1A2B49),
          secondaryText: Color(0xFF5B6B82),
          background: Color(0xFFFFFFFF),
          componentBackground: Color(0xFFF5F7FA),
          componentBorder: Color(0xFFE6EEF7),
          componentDivider: Color(0xFFE6EEF7),
          placeholderText: Color(0xFF5B6B82),
          icon: Color(0xFF003580),
        ),
        shapes: PaymentSheetShape(borderRadius: 16),
      ),
    ),
  );
  try {
    await Stripe.instance.presentPaymentSheet();
  } on StripeException catch (error) {
    final code = error.error.code.toString().toLowerCase();
    if (code.contains('cancel')) {
      throw PaymentSheetCanceled();
    }
    throw PaymentSheetFailed(
      error.error.localizedMessage ?? error.error.message ?? 'Payment failed',
    );
  }
}
