import request from 'supertest';
import { createApp } from '../src/app.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

describe('auth flow', () => {
  it('registers, logs in, and returns the current user', async () => {
    const email = uniqueEmail('customer');
    const password = 'TestPass!234';
    const register = await request(app).post('/api/v1/auth/register').send({
      email,
      password,
      firstName: 'Nour',
      lastName: 'Ali',
      role: 'customer',
    });
    expect(register.status).toBe(201);
    expect(register.body.success).toBe(true);
    expect(register.body.data.user.email).toBe(email);
    expect(register.body.data.tokens.accessToken).toBeTruthy();

    const login = await request(app).post('/api/v1/auth/login').send({ email, password });
    expect(login.status).toBe(200);
    expect(login.body.data.user.role).toBe('CUSTOMER');
    const token = accessToken(login);

    const me = await request(app).get('/api/v1/auth/me').set('Authorization', `Bearer ${token}`);
    expect(me.status).toBe(200);
    expect(me.body.data.user.email).toBe(email);
  });

  it('rejects invalid credentials', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({ email: 'nobody@test.zaya.local', password: 'wrong-pass' });
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });
});
