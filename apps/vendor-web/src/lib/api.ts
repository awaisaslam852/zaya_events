import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { clearSession, getAccessToken, getRefreshToken, setSession } from './auth';

export type ApiSuccess<T> = { success: true; data: T };
export type ApiFailure = { success: false; error: { code: string; message: string } };
export type Paginated<T> = {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  pageCount: number;
};

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? 'http://localhost:4000',
});

api.interceptors.request.use((config) => {
  const token = getAccessToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

let refreshing: Promise<string | null> | null = null;

async function refreshAccess(): Promise<string | null> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) {
    return null;
  }
  const { data } = await axios.post<
    ApiSuccess<{ tokens: { accessToken: string; refreshToken: string }; user: { id: string; email: string; role: string; firstName: string; lastName: string } }>
  >(`${import.meta.env.VITE_API_URL ?? 'http://localhost:4000'}/api/v1/auth/refresh`, { refreshToken });
  if (!data.success || data.data.user.role !== 'VENDOR') {
    clearSession();
    return null;
  }
  setSession({
    accessToken: data.data.tokens.accessToken,
    refreshToken: data.data.tokens.refreshToken,
    user: data.data.user,
  });
  return data.data.tokens.accessToken;
}

api.interceptors.response.use(
  (res) => res,
  async (error: AxiosError<ApiFailure>) => {
    const original = error.config as InternalAxiosRequestConfig & { _retry?: boolean };
    if (error.response?.status === 401 && original && !original._retry && !original.url?.includes('/auth/')) {
      original._retry = true;
      refreshing = refreshing ?? refreshAccess();
      const token = await refreshing;
      refreshing = null;
      if (token) {
        original.headers.Authorization = `Bearer ${token}`;
        return api(original);
      }
      clearSession();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  },
);

export async function unwrap<T>(promise: Promise<{ data: ApiSuccess<T> | ApiFailure }>): Promise<T> {
  const { data } = await promise;
  if (!data.success) {
    throw new Error(data.error.message);
  }
  return data.data;
}
