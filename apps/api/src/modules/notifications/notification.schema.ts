import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const registerDeviceSchema = z.object({
  token: z.string().min(10),
  platform: z.enum(['ios', 'android', 'web']),
});

export const notificationListQuery = paginationQuerySchema.extend({
  unreadOnly: z
    .enum(['true', 'false'])
    .optional()
    .transform((value) => value === 'true'),
});

export const broadcastSchema = z.object({
  title: z.object({ en: z.string().min(1), ar: z.string().min(1) }),
  body: z.object({ en: z.string().min(1), ar: z.string().min(1) }),
  role: z.enum(['CUSTOMER', 'VENDOR']).optional(),
});
