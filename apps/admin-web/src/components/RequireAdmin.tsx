import { Navigate } from 'react-router-dom';
import { isAdminSession } from '@/lib/auth';
import { AdminLayout } from './AdminLayout';

export function RequireAdmin() {
  if (!isAdminSession()) {
    return <Navigate to="/login" replace />;
  }
  return <AdminLayout />;
}
