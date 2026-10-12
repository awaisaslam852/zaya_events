import type { z } from 'zod';
import { sendSuccess } from '../../lib/http.js';
import { actor, handle } from '../../lib/common.js';
import { availabilityService } from './availability.service.js';
import type { availabilityListQuery, availabilityUpsertSchema } from './availability.schema.js';

export const availabilityController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await availabilityService.list(req.query as unknown as z.infer<typeof availabilityListQuery>));
  }),
  create: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await availabilityService.create(user.id, user.role, req.body as z.infer<typeof availabilityUpsertSchema>),
      201,
    );
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await availabilityService.update(
        user.id,
        user.role,
        String(req.params.id),
        req.body as z.infer<typeof availabilityUpsertSchema>,
      ),
    );
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await availabilityService.remove(user.id, user.role, String(req.params.id)));
  }),
};
