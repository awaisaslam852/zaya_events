import { BookingStatus } from '@prisma/client';
import { ALLOWED_TRANSITIONS } from '../src/modules/bookings/booking.schema.js';

describe('booking state machine', () => {
  it('allows pending → under_review → confirmed → completed', () => {
    expect(ALLOWED_TRANSITIONS[BookingStatus.PENDING]).toContain(BookingStatus.UNDER_REVIEW);
    expect(ALLOWED_TRANSITIONS[BookingStatus.UNDER_REVIEW]).toContain(BookingStatus.CONFIRMED);
    expect(ALLOWED_TRANSITIONS[BookingStatus.CONFIRMED]).toContain(BookingStatus.COMPLETED);
  });

  it('blocks reverse and terminal hops', () => {
    expect(ALLOWED_TRANSITIONS[BookingStatus.COMPLETED]).toEqual([]);
    expect(ALLOWED_TRANSITIONS[BookingStatus.CANCELLED]).toEqual([]);
    expect(ALLOWED_TRANSITIONS[BookingStatus.REJECTED]).toEqual([]);
    expect(ALLOWED_TRANSITIONS[BookingStatus.PENDING]).not.toContain(BookingStatus.CONFIRMED);
    expect(ALLOWED_TRANSITIONS[BookingStatus.CONFIRMED]).not.toContain(BookingStatus.PENDING);
  });

  it('lets confirmed bookings cancel or mark paid', () => {
    expect(ALLOWED_TRANSITIONS[BookingStatus.CONFIRMED]).toEqual(
      expect.arrayContaining([BookingStatus.PAID, BookingStatus.COMPLETED, BookingStatus.CANCELLED]),
    );
  });
});
