import { JWT } from 'google-auth-library';
import { env } from '../config/env.js';
import { logger } from '../lib/logger.js';

async function accessToken(): Promise<string | null> {
  if (!env.FCM_PROJECT_ID || !env.FCM_CLIENT_EMAIL || !env.FCM_PRIVATE_KEY) {
    return null;
  }
  const client = new JWT({
    email: env.FCM_CLIENT_EMAIL,
    key: env.FCM_PRIVATE_KEY.replace(/\\n/g, '\n'),
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const { access_token: token } = await client.authorize();
  return token ?? null;
}

export async function sendFcm(params: {
  tokens: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
}): Promise<void> {
  if (params.tokens.length === 0) {
    return;
  }
  const token = await accessToken();
  if (!token) {
    logger.warn('FCM is not configured; push skipped');
    return;
  }
  const url = `https://fcm.googleapis.com/v1/projects/${env.FCM_PROJECT_ID}/messages:send`;
  await Promise.all(
    params.tokens.map(async (deviceToken) => {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          authorization: `Bearer ${token}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: deviceToken,
            notification: { title: params.title, body: params.body },
            data: params.data ?? {},
            android: { priority: 'HIGH' },
            apns: { headers: { 'apns-priority': '10' } },
          },
        }),
      });
      if (!response.ok) {
        const text = await response.text();
        logger.error({ status: response.status, text }, 'FCM send failed');
      }
    }),
  );
}
