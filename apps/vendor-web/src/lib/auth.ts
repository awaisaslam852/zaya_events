const ACCESS = 'zaya.vendor.access';
const REFRESH = 'zaya.vendor.refresh';
const USER = 'zaya.vendor.user';

export type VendorUser = {
  id: string;
  email: string;
  role: string;
  firstName: string;
  lastName: string;
};

export function getAccessToken(): string | null {
  return localStorage.getItem(ACCESS);
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH);
}

export function getUser(): VendorUser | null {
  const raw = localStorage.getItem(USER);
  if (!raw) {
    return null;
  }
  return JSON.parse(raw) as VendorUser;
}

export function setSession(params: { accessToken: string; refreshToken: string; user: VendorUser }): void {
  localStorage.setItem(ACCESS, params.accessToken);
  localStorage.setItem(REFRESH, params.refreshToken);
  localStorage.setItem(USER, JSON.stringify(params.user));
}

export function clearSession(): void {
  localStorage.removeItem(ACCESS);
  localStorage.removeItem(REFRESH);
  localStorage.removeItem(USER);
}

export function isVendorSession(): boolean {
  return getUser()?.role === 'VENDOR' && Boolean(getAccessToken());
}
