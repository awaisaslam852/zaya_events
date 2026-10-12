import request from 'supertest';
import { createApp } from '../src/app.js';
import { accessToken, uniqueEmail } from './helpers.js';

const app = createApp();

describe('upload via storage adapter', () => {
  it('stores a multipart file through the configured driver', async () => {
    const email = uniqueEmail('uploader');
    const password = 'TestPass!234';
    await request(app).post('/api/v1/auth/register').send({
      email,
      password,
      firstName: 'Up',
      lastName: 'Load',
      role: 'customer',
    });
    const token = accessToken(await request(app).post('/api/v1/auth/login').send({ email, password }));
    const res = await request(app)
      .post('/api/v1/uploads')
      .set('Authorization', `Bearer ${token}`)
      .field('folder', 'tests')
      .attach('file', Buffer.from('%PDF-1.4 test'), { filename: 'brief.pdf', contentType: 'application/pdf' });
    expect(res.status).toBe(201);
    expect(res.body.data.key).toContain('tests/');
    expect(res.body.data.url).toContain('/uploads/');
    expect(res.body.data.size).toBeGreaterThan(0);
  });
});
