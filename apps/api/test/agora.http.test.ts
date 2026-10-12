import request from 'supertest';
import { createApp } from '../src/app.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

describe('agora rtc token HTTP', () => {
  it('issues a token for an authenticated user', async () => {
    const email = uniqueEmail('caller');
    const password = 'TestPass!234';
    await request(app).post('/api/v1/auth/register').send({
      email,
      password,
      firstName: 'Call',
      lastName: 'User',
      role: 'customer',
    });
    const token = accessToken(await request(app).post('/api/v1/auth/login').send({ email, password }));
    const res = await request(app)
      .post('/api/v1/agora/rtc-token')
      .set('Authorization', `Bearer ${token}`)
      .send({ channelName: 'call_user_a_user_b', uid: 99, role: 'PUBLISHER' });
    expect(res.status).toBe(200);
    expect(res.body.data.token).toBeTruthy();
    expect(res.body.data.appId).toBeTruthy();
    expect(res.body.data.channelName).toBe('call_user_a_user_b');
  });
});
