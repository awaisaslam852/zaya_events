import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { clearSession, getAccessToken, getRefreshToken, setSession } from './auth';

export type ApiSuccess<T> = { success: true; data: T };
export type ApiFailure = {
  success: false;
  error: { code: string; message: string; details?: { fieldErrors?: Record<string, string[] | undefined> } };
};
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

function formatApiError(error: ApiFailure['error']): string {
  const fields = error.details?.fieldErrors
    ? Object.entries(error.details.fieldErrors)
        .flatMap(([key, messages]) => (messages ?? []).map((message) => `${key}: ${message}`))
        .join('; ')
    : '';
  return fields ? `${error.message} (${fields})` : error.message;
}

export async function unwrap<T>(promise: Promise<{ data: ApiSuccess<T> | ApiFailure }>): Promise<T> {
  try {
    const { data } = await promise;
    if (!data.success) {
      throw new Error(formatApiError(data.error));
    }
    return data.data;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const body = error.response?.data as ApiFailure | undefined;
      if (body && body.success === false && body.error) {
        throw new Error(formatApiError(body.error));
      }
    }
    throw error;
  }
}
