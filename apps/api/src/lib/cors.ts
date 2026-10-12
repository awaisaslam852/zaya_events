import type { CorsOptions } from 'cors';
import { corsOrigins, env } from '../config/env.js';

function isLoopbackHttpOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    const host = url.hostname.replace(/^\[|\]$/g, '');
    const loopback = host === 'localhost' || host === '127.0.0.1' || host === '::1';
    return loopback && (url.protocol === 'http:' || url.protocol === 'https:');
  } catch {
    return false;
  }
}

export function isAllowedCorsOrigin(origin: string | undefined): boolean {
  if (!origin) {
    return true;
  }
  if (corsOrigins.includes('*') || corsOrigins.includes(origin)) {
    return true;
  }
  return env.NODE_ENV !== 'production' && isLoopbackHttpOrigin(origin);
}

export const corsOptions: CorsOptions = {
  origin(origin, callback) {
    if (isAllowedCorsOrigin(origin)) {
      callback(null, true);
      return;
    }
    callback(null, false);
  },
  credentials: true,
  methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Requested-With'],
  maxAge: 86_400,
};
