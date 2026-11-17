import { z } from 'zod';
import { REVIEW_MAX, REVIEW_MIN } from './review.rules.js';

export const reviewBodySchema = z.object({
  rating: z.coerce.number().int().min(REVIEW_MIN).max(REVIEW_MAX),
  comment: z.string().trim().max(800).optional(),
});
