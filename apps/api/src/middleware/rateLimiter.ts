import rateLimit from 'express-rate-limit';
import { RedisStore } from 'rate-limit-redis';
import { env } from '../config/env.js';
import { redis } from '../lib/redis.js';

export const apiRateLimiter = rateLimit({
  windowMs: env.RATE_LIMIT_WINDOW_MS,
  limit: env.RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) =>
    env.NODE_ENV === 'test' ||
    req.method === 'OPTIONS' ||
    req.path === '/health' ||
    req.path === '/api/docs',
  ...(env.NODE_ENV === 'test'
    ? {}
    : {
        store: new RedisStore({
          sendCommand: (...args: string[]) =>
            redis.call(args[0]!, ...args.slice(1)) as Promise<
              string | number | boolean | Array<string | number | boolean>
            >,
        }),
      }),
  message: {
    success: false,
    error: { code: 'RATE_LIMITED', message: 'Too many requests' },
  },
});
