class CountryOption {
  const CountryOption(this.code, this.name, this.nameAr);
  final String code;
  final String name;
  final String nameAr;

  String localizedName(String languageCode) => languageCode.startsWith('ar') ? nameAr : name;

  String get flagEmoji {
    final units = code.toUpperCase().codeUnits;
    if (units.length != 2) {
      return '🌍';
    }
    return String.fromCharCodes(units.map((unit) => 0x1F1E6 - 0x41 + unit));
  }

  String label(String languageCode) => '${localizedName(languageCode)} ($code)';
}

CountryOption? countryByCode(String? code) {
  if (code == null || code.isEmpty) {
    return null;
  }
  final needle = code.toUpperCase();
  for (final country in kCountries) {
    if (country.code == needle) {
      return country;
    }
  }
  return null;
}

List<CountryOption> filterCountries(String query, {String languageCode = 'en'}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return List<CountryOption>.from(kCountries);
  }
  return kCountries.where((country) {
    return country.code.toLowerCase().contains(q) ||
        country.name.toLowerCase().contains(q) ||
        country.nameAr.contains(query.trim()) ||
        country.localizedName(languageCode).toLowerCase().contains(q);
  }).toList();
}

const kCountries = [
  CountryOption('AE', 'United Arab Emirates', 'الإمارات العربية المتحدة'),
  CountryOption('SA', 'Saudi Arabia', 'المملكة العربية السعودية'),
  CountryOption('QA', 'Qatar', 'قطر'),
  CountryOption('KW', 'Kuwait', 'الكويت'),
  CountryOption('BH', 'Bahrain', 'البحرين'),
  CountryOption('OM', 'Oman', 'عُمان'),
  CountryOption('JO', 'Jordan', 'الأردن'),
  CountryOption('EG', 'Egypt', 'مصر'),
  CountryOption('LB', 'Lebanon', 'لبنان'),
  CountryOption('IQ', 'Iraq', 'العراق'),
  CountryOption('PS', 'Palestine', 'فلسطين'),
  CountryOption('TR', 'Turkey', 'تركيا'),
  CountryOption('GB', 'United Kingdom', 'المملكة المتحدة'),
  CountryOption('US', 'United States', 'الولايات المتحدة'),
  CountryOption('IN', 'India', 'الهند'),
  CountryOption('PK', 'Pakistan', 'باكستان'),
  CountryOption('PH', 'Philippines', 'الفلبين'),
  CountryOption('CN', 'China', 'الصين'),
  CountryOption('FR', 'France', 'فرنسا'),
  CountryOption('DE', 'Germany', 'ألمانيا'),
  CountryOption('IT', 'Italy', 'إيطاليا'),
  CountryOption('ES', 'Spain', 'إسبانيا'),
  CountryOption('CA', 'Canada', 'كندا'),
  CountryOption('AU', 'Australia', 'أستراليا'),
  CountryOption('KE', 'Kenya', 'كينيا'),
  CountryOption('NG', 'Nigeria', 'نيجيريا'),
  CountryOption('ZA', 'South Africa', 'جنوب أفريقيا'),
  CountryOption('MA', 'Morocco', 'المغرب'),
  CountryOption('SG', 'Singapore', 'سنغافورة'),
  CountryOption('MY', 'Malaysia', 'ماليزيا'),
];
