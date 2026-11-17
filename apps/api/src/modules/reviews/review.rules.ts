import { BookingStatus, ReviewDirection, Role } from '@prisma/client';

export const REVIEW_MIN = 1;
export const REVIEW_MAX = 5;

export function reviewDirectionForRole(role: Role): ReviewDirection | null {
  if (role === Role.CUSTOMER) {
    return ReviewDirection.CUSTOMER_TO_VENDOR;
  }
  if (role === Role.VENDOR) {
    return ReviewDirection.VENDOR_TO_CUSTOMER;
  }
  return null;
}

export function bookingAllowsReview(status: BookingStatus | string): boolean {
  return status === BookingStatus.COMPLETED || status === 'COMPLETED';
}
