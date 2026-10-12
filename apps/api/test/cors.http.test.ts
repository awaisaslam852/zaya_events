import request from 'supertest';
import { createApp } from '../src/app.js';

const app = createApp();

describe('CORS preflight for Flutter web / Dio JSON', () => {
  it('answers OPTIONS with allow-origin for localhost Flutter web', async () => {
    const res = await request(app)
      .options('/api/v1/auth/login')
      .set('Origin', 'http://localhost:8080')
      .set('Access-Control-Request-Method', 'POST')
      .set('Access-Control-Request-Headers', 'content-type,authorization');

    expect(res.status).toBe(204);
    expect(res.headers['access-control-allow-origin']).toBe('http://localhost:8080');
    expect(res.headers['access-control-allow-credentials']).toBe('true');
    expect(String(res.headers['access-control-allow-headers']).toLowerCase()).toContain(
      'content-type',
    );
  });

  it('reflects 127.0.0.1 on a login POST', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .set('Origin', 'http://127.0.0.1:5555')
      .send({ email: 'nobody@test.zaya.local', password: 'wrong-pass' });

    expect(res.headers['access-control-allow-origin']).toBe('http://127.0.0.1:5555');
  });
});
