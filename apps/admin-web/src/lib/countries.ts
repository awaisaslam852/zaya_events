import { getUser } from './auth';

export const COUNTRIES = [
  { code: 'AE', name: 'United Arab Emirates' },
  { code: 'SA', name: 'Saudi Arabia' },
  { code: 'QA', name: 'Qatar' },
  { code: 'KW', name: 'Kuwait' },
  { code: 'BH', name: 'Bahrain' },
  { code: 'OM', name: 'Oman' },
  { code: 'JO', name: 'Jordan' },
  { code: 'EG', name: 'Egypt' },
  { code: 'LB', name: 'Lebanon' },
  { code: 'IQ', name: 'Iraq' },
  { code: 'PS', name: 'Palestine' },
  { code: 'TR', name: 'Turkey' },
  { code: 'GB', name: 'United Kingdom' },
  { code: 'US', name: 'United States' },
  { code: 'IN', name: 'India' },
  { code: 'PK', name: 'Pakistan' },
  { code: 'PH', name: 'Philippines' },
  { code: 'CN', name: 'China' },
  { code: 'FR', name: 'France' },
  { code: 'DE', name: 'Germany' },
  { code: 'IT', name: 'Italy' },
  { code: 'ES', name: 'Spain' },
  { code: 'CA', name: 'Canada' },
  { code: 'AU', name: 'Australia' },
  { code: 'KE', name: 'Kenya' },
  { code: 'NG', name: 'Nigeria' },
  { code: 'ZA', name: 'South Africa' },
  { code: 'MA', name: 'Morocco' },
  { code: 'SG', name: 'Singapore' },
  { code: 'MY', name: 'Malaysia' },
] as const;

export const APP_CURRENCIES = [
  'AED',
  'SAR',
  'QAR',
  'KWD',
  'BHD',
  'OMR',
  'JOD',
  'EGP',
  'LBP',
  'IQD',
  'ILS',
  'TRY',
  'GBP',
  'USD',
  'INR',
  'PKR',
  'PHP',
  'CNY',
  'EUR',
  'CAD',
  'AUD',
  'KES',
  'NGN',
  'ZAR',
  'MAD',
  'SGD',
  'MYR',
] as const;

export const COUNTRY_CURRENCY: Record<string, string> = {
  AE: 'AED',
  SA: 'SAR',
  QA: 'QAR',
  KW: 'KWD',
  BH: 'BHD',
  OM: 'OMR',
  JO: 'JOD',
  EG: 'EGP',
  LB: 'LBP',
  IQ: 'IQD',
  PS: 'ILS',
  TR: 'TRY',
  GB: 'GBP',
  US: 'USD',
  IN: 'INR',
  PK: 'PKR',
  PH: 'PHP',
  CN: 'CNY',
  FR: 'EUR',
  DE: 'EUR',
  IT: 'EUR',
  ES: 'EUR',
  CA: 'CAD',
  AU: 'AUD',
  KE: 'KES',
  NG: 'NGN',
  ZA: 'ZAR',
  MA: 'MAD',
  SG: 'SGD',
  MY: 'MYR',
};

export const COUNTRY_NAME_AR: Record<string, string> = {
  AE: 'الإمارات العربية المتحدة',
  SA: 'المملكة العربية السعودية',
  QA: 'قطر',
  KW: 'الكويت',
  BH: 'البحرين',
  OM: 'عُمان',
  JO: 'الأردن',
  EG: 'مصر',
  LB: 'لبنان',
  IQ: 'العراق',
  PS: 'فلسطين',
  TR: 'تركيا',
  GB: 'المملكة المتحدة',
  US: 'الولايات المتحدة',
  IN: 'الهند',
  PK: 'باكستان',
  PH: 'الفلبين',
  CN: 'الصين',
  FR: 'فرنسا',
  DE: 'ألمانيا',
  IT: 'إيطاليا',
  ES: 'إسبانيا',
  CA: 'كندا',
  AU: 'أستراليا',
  KE: 'كينيا',
  NG: 'نيجيريا',
  ZA: 'جنوب أفريقيا',
  MA: 'المغرب',
  SG: 'سنغافورة',
  MY: 'ماليزيا',
};

function uiLang(): string {
  if (typeof document !== 'undefined' && document.documentElement.lang) {
    return document.documentElement.lang;
  }
  return 'en';
}

export function currencyForCountry(country?: string | null, fallback = 'AED'): string {
  if (!country) {
    return fallback;
  }
  return COUNTRY_CURRENCY[country] ?? fallback;
}

export function assignableCountries(): Array<{ code: string; name: string }> {
  const user = getUser();
  const rows = !user || user.isSuperAdmin
    ? COUNTRIES
    : COUNTRIES.filter((row) => user.allowedCountries.includes(row.code));
  return rows.map((row) => ({ code: row.code, name: countryName(row.code) }));
}

export function defaultCountry(): string {
  return assignableCountries()[0]?.code ?? 'AE';
}

export function countryName(code: string, lang = uiLang()): string {
  const row = COUNTRIES.find((item) => item.code === code);
  if (!row) {
    return code;
  }
  return lang.startsWith('ar') ? COUNTRY_NAME_AR[code] ?? row.name : row.name;
}
