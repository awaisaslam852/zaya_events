const ACCESS = 'zaya.admin.access';
const REFRESH = 'zaya.admin.refresh';
const USER = 'zaya.admin.user';

export type AdminUser = {
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

export function getUser(): AdminUser | null {
  const raw = localStorage.getItem(USER);
  if (!raw) {
    return null;
  }
  return JSON.parse(raw) as AdminUser;
}

export function setSession(params: { accessToken: string; refreshToken: string; user: AdminUser }): void {
  localStorage.setItem(ACCESS, params.accessToken);
  localStorage.setItem(REFRESH, params.refreshToken);
  localStorage.setItem(USER, JSON.stringify(params.user));
}

export function clearSession(): void {
  localStorage.removeItem(ACCESS);
  localStorage.removeItem(REFRESH);
  localStorage.removeItem(USER);
}

export function isAdminSession(): boolean {
  return getUser()?.role === 'ADMIN' && Boolean(getAccessToken());
}
