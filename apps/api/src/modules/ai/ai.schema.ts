import { z } from 'zod';

export const aiChatSchema = z.object({
  messages: z.array(
    z.object({
      role: z.enum(['user', 'assistant']),
      content: z.string().min(1).max(8000),
    }),
  ),
  eventId: z.string().uuid().optional(),
  locale: z.enum(['en', 'ar']).default('en'),
});

export const aiEventRefSchema = z.object({
  eventId: z.string().uuid(),
  locale: z.enum(['en', 'ar']).default('en'),
});
