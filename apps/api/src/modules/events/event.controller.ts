import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { eventService } from './event.service.js';
import type { eventBody, eventListQuery, eventPatch } from './event.schema.js';

export const eventController = {
  list: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await eventService.list(user.id, user.role, req.query as unknown as z.infer<typeof eventListQuery>));
  }),
  get: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await eventService.get(user.id, user.role, String(req.params.id)));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await eventService.create(actor(req).id, req.body as z.infer<typeof eventBody>), 201);
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await eventService.update(user.id, user.role, String(req.params.id), req.body as z.infer<typeof eventPatch>),
    );
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await eventService.remove(user.id, user.role, String(req.params.id)));
  }),
};
