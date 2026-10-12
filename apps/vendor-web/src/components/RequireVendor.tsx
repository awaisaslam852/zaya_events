import { Navigate } from 'react-router-dom';
import { isVendorSession } from '@/lib/auth';
import { VendorLayout } from './VendorLayout';

export function RequireVendor() {
  if (!isVendorSession()) {
    return <Navigate to="/login" replace />;
  }
  return <VendorLayout />;
}
