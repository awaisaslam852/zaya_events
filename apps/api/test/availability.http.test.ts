import bcrypt from 'bcryptjs';
import request from 'supertest';
import { Role, UserStatus } from '@prisma/client';
import { createApp } from '../src/app.js';
import { env } from '../src/config/env.js';
import { prisma } from '../src/lib/prisma.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

describe('availability overlap HTTP', () => {
  it('returns AVAILABILITY_OVERLAP when a second blocked slot collides', async () => {
    const email = uniqueEmail('admin-avail');
    const password = 'AdminPass!234';
    await prisma.user.create({
      data: {
        email,
        passwordHash: await bcrypt.hash(password, env.BCRYPT_ROUNDS),
        role: Role.ADMIN,
        status: UserStatus.ACTIVE,
        firstName: 'Avail',
        lastName: 'Admin',
      },
    });
    const venue = await prisma.venue.create({
      data: {
        name: { en: 'Overlap Hall', ar: 'قاعة' },
        description: { en: 'Hall', ar: 'قاعة' },
        address: { en: 'Dubai', ar: 'دبي' },
        city: 'Dubai',
        country: 'AE',
        latitude: 25.1,
        longitude: 55.2,
        capacityMin: 10,
        capacityMax: 100,
        amenities: [],
        galleryKeys: [],
      },
    });
    const token = accessToken(await request(app).post('/api/v1/auth/login').send({ email, password }));
    const startAt = '2026-11-01T10:00:00.000Z';
    const endAt = '2026-11-01T14:00:00.000Z';
    const first = await request(app)
      .post('/api/v1/availability')
      .set('Authorization', `Bearer ${token}`)
      .send({
        resourceType: 'VENUE',
        resourceId: venue.id,
        startAt,
        endAt,
        status: 'UNAVAILABLE',
        isBlocked: true,
      });
    expect(first.status).toBe(201);

    const second = await request(app)
      .post('/api/v1/availability')
      .set('Authorization', `Bearer ${token}`)
      .send({
        resourceType: 'VENUE',
        resourceId: venue.id,
        startAt: '2026-11-01T13:00:00.000Z',
        endAt: '2026-11-01T16:00:00.000Z',
        status: 'UNAVAILABLE',
        isBlocked: true,
      });
    expect(second.status).toBe(409);
    expect(second.body.error.code).toBe('AVAILABILITY_OVERLAP');
  });
});
