class PaymentCheckoutArgs {
  const PaymentCheckoutArgs({
    required this.bookingId,
    required this.paymentId,
    required this.clientSecret,
    required this.publishableKey,
    required this.amount,
    required this.currency,
    required this.kind,
    this.title,
  });

  final String bookingId;
  final String paymentId;
  final String clientSecret;
  final String publishableKey;
  final dynamic amount;
  final String currency;
  final String kind;
  final String? title;

  bool get isReady =>
      paymentId.isNotEmpty && clientSecret.isNotEmpty && publishableKey.isNotEmpty;

  factory PaymentCheckoutArgs.fromIntent({
    required String bookingId,
    required Map<String, dynamic> data,
    String? title,
  }) {
    final payment = data['payment'] is Map
        ? Map<String, dynamic>.from(data['payment'] as Map)
        : <String, dynamic>{};
    return PaymentCheckoutArgs(
      bookingId: bookingId,
      paymentId: payment['id']?.toString() ?? '',
      clientSecret: data['clientSecret']?.toString() ?? '',
      publishableKey: data['publishableKey']?.toString() ?? '',
      amount: payment['amount'],
      currency: payment['currency']?.toString() ?? 'AED',
      kind: payment['kind']?.toString() ?? '',
      title: title,
    );
  }
}
