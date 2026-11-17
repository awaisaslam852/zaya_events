class CartTotals {
  const CartTotals({required this.items});

  final List<Map<String, dynamic>> items;

  num get subtotal => items.fold<num>(
        0,
        (sum, item) => sum + (num.tryParse('${item['unitAmount'] ?? 0}') ?? 0),
      );

  num get deposit => (subtotal * 0.3 * 100).round() / 100;

  String get currency => items.isEmpty ? 'AED' : (items.first['currency']?.toString() ?? 'AED');

  int get count => items.length;
}
