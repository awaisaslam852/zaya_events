import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { reviewService } from './review.service.js';
import type { reviewBodySchema } from './review.schema.js';

export const reviewController = {
  create: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await reviewService.create(user.id, user.role, String(req.params.id), req.body as z.infer<typeof reviewBodySchema>),
      201,
    );
  }),
};
