import bcrypt from 'bcryptjs';
import request from 'supertest';
import { Role, UserStatus, VendorStatus } from '@prisma/client';
import { createApp } from '../src/app.js';
import { env } from '../src/config/env.js';
import { prisma } from '../src/lib/prisma.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

describe('booking reviews', () => {
  it('blocks reviews until completed, then lets each party write once', async () => {
    const vendorPassword = 'VendorPass!234';
    const vendorUser = await prisma.user.create({
      data: {
        email: uniqueEmail('review-vendor'),
        passwordHash: await bcrypt.hash(vendorPassword, env.BCRYPT_ROUNDS),
        role: Role.VENDOR,
        status: UserStatus.ACTIVE,
        firstName: 'V',
        lastName: 'Endor',
      },
    });
    const vendor = await prisma.vendor.create({
      data: {
        userId: vendorUser.id,
        businessName: { en: 'Review Halls', ar: 'قاعات التقييم' },
        description: { en: 'Test', ar: 'تجريبي' },
        status: VendorStatus.APPROVED,
      },
    });
    const venue = await prisma.venue.create({
      data: {
        vendorId: vendor.id,
        name: { en: 'Review Hall', ar: 'قاعة التقييم' },
        description: { en: 'Hall', ar: 'قاعة' },
        address: { en: 'Dubai', ar: 'دبي' },
        city: 'Dubai',
        country: 'AE',
        latitude: 25.2,
        longitude: 55.3,
        capacityMin: 50,
        capacityMax: 400,
        amenities: [],
        galleryKeys: [],
        isPublished: true,
      },
    });
    const customerEmail = uniqueEmail('review-guest');
    await request(app).post('/api/v1/auth/register').send({
      email: customerEmail,
      password: 'TestPass!234',
      firstName: 'Sara',
      lastName: 'Hassan',
      role: 'customer',
    });
    const customerToken = accessToken(
      await request(app).post('/api/v1/auth/login').send({ email: customerEmail, password: 'TestPass!234' }),
    );
    const vendorToken = accessToken(
      await request(app).post('/api/v1/auth/login').send({ email: vendorUser.email, password: vendorPassword }),
    );
    const created = await request(app)
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({
        type: 'VENUE',
        venueId: venue.id,
        startAt: new Date(Date.now() + 86400000).toISOString(),
        endAt: new Date(Date.now() + 86400000 + 4 * 3600000).toISOString(),
        guestCount: 40,
      });
    const bookingId = created.body.data.id as string;
    const tooSoon = await request(app)
      .post(`/api/v1/bookings/${bookingId}/reviews`)
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ rating: 5, comment: 'Too early' });
    expect(tooSoon.status).toBe(422);
    expect(tooSoon.body.error.code).toBe('REVIEW_NOT_READY');

    await request(app).post(`/api/v1/bookings/${bookingId}/confirm`).set('Authorization', `Bearer ${vendorToken}`).send({});
    await request(app).post(`/api/v1/bookings/${bookingId}/complete`).set('Authorization', `Bearer ${vendorToken}`).send({});

    const guestReview = await request(app)
      .post(`/api/v1/bookings/${bookingId}/reviews`)
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ rating: 5, comment: 'Beautiful hall' });
    expect(guestReview.status).toBe(201);
    expect(guestReview.body.data.direction).toBe('CUSTOMER_TO_VENDOR');
    expect(guestReview.body.data.rating).toBe(5);

    const duplicate = await request(app)
      .post(`/api/v1/bookings/${bookingId}/reviews`)
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ rating: 4 });
    expect(duplicate.status).toBe(409);

    const vendorReview = await request(app)
      .post(`/api/v1/bookings/${bookingId}/reviews`)
      .set('Authorization', `Bearer ${vendorToken}`)
      .send({ rating: 4, comment: 'Lovely guests' });
    expect(vendorReview.status).toBe(201);
    expect(vendorReview.body.data.direction).toBe('VENDOR_TO_CUSTOMER');

    const customerView = await request(app)
      .get(`/api/v1/bookings/${bookingId}`)
      .set('Authorization', `Bearer ${customerToken}`);
    expect(customerView.body.data.reviewState.canWrite).toBe(false);
    expect(customerView.body.data.reviewState.mine.rating).toBe(5);
    expect(customerView.body.data.reviewState.theirs.rating).toBe(4);

    const publicVenue = await request(app).get(`/api/v1/venues/${venue.id}`);
    expect(publicVenue.body.data.reviews.some((row: { rating: number }) => row.rating === 5)).toBe(true);
    expect(publicVenue.body.data.reviews.some((row: { direction: string }) => row.direction === 'VENDOR_TO_CUSTOMER')).toBe(
      false,
    );
  });
});
