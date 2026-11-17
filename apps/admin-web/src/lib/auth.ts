const ACCESS = 'zaya.admin.access';
const REFRESH = 'zaya.admin.refresh';
const USER = 'zaya.admin.user';
const DESK = 'zaya.admin.deskCountry';

export type AdminUser = {
  id: string;
  email: string;
  role: string;
  firstName: string;
  lastName: string;
  isSuperAdmin: boolean;
  allowedCountries: string[];
};

export type AdminSessionUser = {
  id: string;
  email: string;
  role: string;
  firstName: string;
  lastName: string;
  isSuperAdmin?: boolean;
  allowedCountries?: string[];
};

export function toAdminUser(user: AdminSessionUser): AdminUser {
  return {
    id: user.id,
    email: user.email,
    role: user.role,
    firstName: user.firstName,
    lastName: user.lastName,
    isSuperAdmin: Boolean(user.isSuperAdmin),
    allowedCountries: user.allowedCountries ?? [],
  };
}

export function getAccessToken(): string | null {
  return localStorage.getItem(ACCESS);
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH);
}

export function getUser(): AdminUser | null {
  const raw = localStorage.getItem(USER);
  if (!raw) {
    return null;
  }
  return toAdminUser(JSON.parse(raw) as AdminSessionUser);
}

export function setSession(params: { accessToken: string; refreshToken: string; user: AdminSessionUser }): void {
  localStorage.setItem(ACCESS, params.accessToken);
  localStorage.setItem(REFRESH, params.refreshToken);
  localStorage.setItem(USER, JSON.stringify(toAdminUser(params.user)));
}

export function clearSession(): void {
  localStorage.removeItem(ACCESS);
  localStorage.removeItem(REFRESH);
  localStorage.removeItem(USER);
}

export function isAdminSession(): boolean {
  return getUser()?.role === 'ADMIN' && Boolean(getAccessToken());
}

export function isSuperAdmin(): boolean {
  return Boolean(getUser()?.isSuperAdmin);
}

export function getDeskCountry(): string | null {
  const stored = localStorage.getItem(DESK);
  if (!stored || stored.length !== 2) {
    return null;
  }
  return stored;
}

export function setDeskCountry(code: string | null): void {
  if (!code) {
    localStorage.removeItem(DESK);
    return;
  }
  localStorage.setItem(DESK, code.toUpperCase());
}
