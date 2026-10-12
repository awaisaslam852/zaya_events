class VenuesItem {
  const VenuesItem(this.raw);
  final Map<String, dynamic> raw;
  String get id => raw['id']?.toString() ?? '';
}
