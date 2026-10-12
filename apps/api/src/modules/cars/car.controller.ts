import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { carService } from './car.service.js';
import type { carBody, carBookSchema, carListQuery, carPatch } from './car.schema.js';

export const carController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await carService.list(req.query as unknown as z.infer<typeof carListQuery>, req.user));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await carService.get(String(req.params.id)));
  }),
  calendar: handle(async (req, res) => {
    const from = typeof req.query.from === 'string' ? new Date(req.query.from) : undefined;
    const to = typeof req.query.to === 'string' ? new Date(req.query.to) : undefined;
    sendSuccess(res, await carService.calendar(String(req.params.id), from, to));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await carService.create(actor(req).id, req.body as z.infer<typeof carBody>), 201);
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await carService.update(user.id, user.role, String(req.params.id), req.body as z.infer<typeof carPatch>));
  }),
  book: handle(async (req, res) => {
    sendSuccess(res, await carService.book(actor(req).id, String(req.params.id), req.body as z.infer<typeof carBookSchema>), 201);
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await carService.remove(user.id, user.role, String(req.params.id)));
  }),
};
