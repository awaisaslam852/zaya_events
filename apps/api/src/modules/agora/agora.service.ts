import { createRequire } from 'node:module';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';

const require = createRequire(import.meta.url);
const agora = require('agora-access-token') as {
  RtcRole: { PUBLISHER: 1; SUBSCRIBER: 2 };
  RtcTokenBuilder: {
    buildTokenWithUid: (
      appId: string,
      appCertificate: string,
      channelName: string,
      uid: number,
      role: 1 | 2,
      privilegeExpiredTs: number,
    ) => string;
  };
};

export type AgoraRtcRole = 'PUBLISHER' | 'SUBSCRIBER';

export function generateRtcToken(
  channelName: string,
  uid: number,
  role: AgoraRtcRole,
  expireSeconds = env.AGORA_TOKEN_EXPIRES_IN,
): {
  token: string;
  appId: string;
  channelName: string;
  uid: number;
  role: AgoraRtcRole;
  expiresAt: number;
} {
  if (!env.AGORA_APP_ID || !env.AGORA_APP_CERTIFICATE) {
    throw new AppError(500, 'AGORA_MISCONFIGURED', 'Agora App ID and certificate must be set on the server');
  }
  if (!channelName.startsWith('booking_') && !channelName.startsWith('call_')) {
    throw new AppError(422, 'INVALID_CHANNEL', 'Channel must be booking_<bookingId> or call_<a>_<b>');
  }
  const privilegeExpiredTs = Math.floor(Date.now() / 1000) + expireSeconds;
  const rtcRole = role === 'PUBLISHER' ? agora.RtcRole.PUBLISHER : agora.RtcRole.SUBSCRIBER;
  const token = agora.RtcTokenBuilder.buildTokenWithUid(
    env.AGORA_APP_ID,
    env.AGORA_APP_CERTIFICATE,
    channelName,
    uid,
    rtcRole,
    privilegeExpiredTs,
  );
  return {
    token,
    appId: env.AGORA_APP_ID,
    channelName,
    uid,
    role,
    expiresAt: privilegeExpiredTs,
  };
}
