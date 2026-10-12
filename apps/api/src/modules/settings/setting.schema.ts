import { z } from 'zod';

export const settingListQuery = z.object({
  group: z.string().optional(),
});

export const settingBody = z.object({
  key: z.string().min(1).max(120),
  group: z.string().min(1).max(60).default('general'),
  value: z.unknown(),
});

export const settingPatch = z.object({
  group: z.string().min(1).max(60).optional(),
  value: z.unknown(),
});
