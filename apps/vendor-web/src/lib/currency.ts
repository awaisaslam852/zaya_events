import { api, unwrap } from '@/lib/api';

let current = 'AED';

export function getAppCurrency(): string {
  return current;
}

export function setAppCurrency(code: string): void {
  if (code.trim()) {
    current = code.trim().toUpperCase();
  }
}

export async function loadAppCurrency(): Promise<string> {
  try {
    const data = await unwrap<{ currency?: string }>(api.get('/api/v1/settings/public'));
    if (data.currency) {
      setAppCurrency(data.currency);
    }
  } catch {
    /* keep last known currency */
  }
  return current;
}
