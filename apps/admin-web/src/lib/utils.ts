import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { getAppCurrency } from '@/lib/currency';

export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

export type Localized = { en: string; ar: string };

export function asLoc(value: unknown): Localized {
  if (value && typeof value === 'object' && 'en' in value) {
    const rec = value as Localized;
    return { en: rec.en || '', ar: rec.ar || rec.en || '' };
  }
  const text = typeof value === 'string' ? value : '';
  return { en: text, ar: text };
}

export function loc(value: unknown, lang: string): string {
  if (!value) {
    return '';
  }
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'object' && value !== null && 'en' in value) {
    const rec = value as Localized;
    return lang.startsWith('ar') ? rec.ar || rec.en : rec.en || rec.ar;
  }
  return String(value);
}

export function money(amount: unknown, currency = getAppCurrency()): string {
  const n = Number(amount ?? 0);
  return `${n.toLocaleString()} ${currency}`;
}

export function mediaUrl(src: string): string {
  if (!src) {
    return '';
  }
  const api = (import.meta.env.VITE_API_URL as string | undefined) ?? 'http://localhost:4000';
  const origin = api.replace(/\/api\/v1\/?$/, '');
  let path = src.trim();
  if (!path) {
    return '';
  }
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path.replace(/https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?/g, origin);
  }
  if (!path.startsWith('/')) {
    path = `/uploads/${path.replace(/^uploads\//, '')}`;
  }
  return `${origin}${path}`;
}

export function coverOf(item: { coverKey?: string | null; galleryKeys?: unknown } | null | undefined): string {
  if (!item) {
    return '';
  }
  const gallery = item.galleryKeys;
  const first = Array.isArray(gallery) ? String(gallery[0] ?? '') : '';
  const raw = item.coverKey || first;
  return raw ? mediaUrl(raw) : '';
}

export function initials(first?: string | null, last?: string | null): string {
  return `${(first ?? '').slice(0, 1)}${(last ?? '').slice(0, 1)}`.toUpperCase() || 'Z';
}
