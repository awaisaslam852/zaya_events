import bcrypt from 'bcryptjs';
import request from 'supertest';
import { Role, UserStatus, VendorStatus } from '@prisma/client';
import { createApp } from '../src/app.js';
import { env } from '../src/config/env.js';
import { prisma } from '../src/lib/prisma.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

async function seedAdmin(): Promise<{ email: string; password: string }> {
  const email = uniqueEmail('admin');
  const password = 'AdminPass!234';
  const passwordHash = await bcrypt.hash(password, env.BCRYPT_ROUNDS);
  await prisma.user.create({
    data: {
      email,
      passwordHash,
      role: Role.ADMIN,
      status: UserStatus.ACTIVE,
      firstName: 'Test',
      lastName: 'Admin',
      displayName: 'Test Admin',
      emailVerifiedAt: new Date(),
    },
  });
  return { email, password };
}

async function seedVenue(): Promise<string> {
  const vendorUser = await prisma.user.create({
    data: {
      email: uniqueEmail('vendor'),
      passwordHash: await bcrypt.hash('VendorPass!234', env.BCRYPT_ROUNDS),
      role: Role.VENDOR,
      status: UserStatus.ACTIVE,
      firstName: 'V',
      lastName: 'Endor',
    },
  });
  const vendor = await prisma.vendor.create({
    data: {
      userId: vendorUser.id,
      businessName: { en: 'Test Vendor', ar: 'مورد تجريبي' },
      description: { en: 'Test', ar: 'تجريبي' },
      status: VendorStatus.APPROVED,
    },
  });
  const venue = await prisma.venue.create({
    data: {
      vendorId: vendor.id,
      name: { en: 'Palm Hall', ar: 'قاعة النخيل' },
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
  return venue.id;
}

describe('booking HTTP state machine', () => {
  it('walks pending → under_review → confirmed → completed and rejects an illegal hop', async () => {
    const admin = await seedAdmin();
    const venueId = await seedVenue();
    const email = uniqueEmail('booker');
    const password = 'TestPass!234';
    await request(app).post('/api/v1/auth/register').send({
      email,
      password,
      firstName: 'Sara',
      lastName: 'Hassan',
      role: 'customer',
    });
    const customerLogin = await request(app).post('/api/v1/auth/login').send({ email, password });
    const customerToken = accessToken(customerLogin);
    const startAt = new Date(Date.now() + 86400000).toISOString();
    const endAt = new Date(Date.now() + 86400000 + 4 * 3600000).toISOString();

    const created = await request(app)
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ type: 'VENUE', venueId, startAt, endAt, guestCount: 80 });
    expect(created.status).toBe(201);
    expect(created.body.data.status).toBe('PENDING');
    const bookingId = created.body.data.id as string;

    const adminLogin = await request(app).post('/api/v1/auth/login').send(admin);
    const adminToken = accessToken(adminLogin);
    const headers = { Authorization: `Bearer ${adminToken}` };

    const review = await request(app).post(`/api/v1/bookings/${bookingId}/under-review`).set(headers).send({});
    expect(review.status).toBe(200);
    expect(review.body.data.status).toBe('UNDER_REVIEW');

    const confirm = await request(app).post(`/api/v1/bookings/${bookingId}/confirm`).set(headers).send({});
    expect(confirm.status).toBe(200);
    expect(confirm.body.data.status).toBe('CONFIRMED');

    const complete = await request(app).post(`/api/v1/bookings/${bookingId}/complete`).set(headers).send({});
    expect(complete.status).toBe(200);
    expect(complete.body.data.status).toBe('COMPLETED');

    const illegal = await request(app).post(`/api/v1/bookings/${bookingId}/confirm`).set(headers).send({});
    expect(illegal.status).toBe(422);
    expect(illegal.body.error.code).toBe('INVALID_TRANSITION');
  });
});
