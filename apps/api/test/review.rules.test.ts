import { BookingStatus, ReviewDirection, Role } from '@prisma/client';
import { bookingAllowsReview, reviewDirectionForRole } from '../src/modules/reviews/review.rules.js';

describe('review rules', () => {
  it('lets customers rate vendors and vendors rate guests', () => {
    expect(reviewDirectionForRole(Role.CUSTOMER)).toBe(ReviewDirection.CUSTOMER_TO_VENDOR);
    expect(reviewDirectionForRole(Role.VENDOR)).toBe(ReviewDirection.VENDOR_TO_CUSTOMER);
    expect(reviewDirectionForRole(Role.ADMIN)).toBeNull();
  });

  it('opens reviews only after the booking is completed', () => {
    expect(bookingAllowsReview(BookingStatus.COMPLETED)).toBe(true);
    expect(bookingAllowsReview(BookingStatus.CONFIRMED)).toBe(false);
    expect(bookingAllowsReview(BookingStatus.PAID)).toBe(false);
    expect(bookingAllowsReview(BookingStatus.CANCELLED)).toBe(false);
  });
});
