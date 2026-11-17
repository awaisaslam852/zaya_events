import { useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { api, unwrap } from '@/lib/api';
import {
  clearSession,
  getAccessToken,
  getRefreshToken,
  isAdminSession,
  isSuperAdmin,
  setSession,
  type AdminSessionUser,
} from '@/lib/auth';
import { AdminLayout } from './AdminLayout';

export function RequireAdmin() {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (!isAdminSession()) {
      setReady(true);
      return;
    }
    const accessToken = getAccessToken();
    const refreshToken = getRefreshToken();
    void unwrap<{ user: AdminSessionUser }>(api.get('/api/v1/auth/me'))
      .then((data) => {
        const user = data.user;
        if (user.role !== 'ADMIN' || !accessToken || !refreshToken) {
          clearSession();
          return;
        }
        setSession({ accessToken, refreshToken, user });
      })
      .catch(() => undefined)
      .finally(() => setReady(true));
  }, []);

  if (!isAdminSession()) {
    return <Navigate to="/login" replace />;
  }
  if (!ready) {
    return null;
  }
  return <AdminLayout />;
}

export function RequireSuperAdmin({ children }: { children: JSX.Element }) {
  if (!isSuperAdmin()) {
    return <Navigate to="/" replace />;
  }
  return children;
}
