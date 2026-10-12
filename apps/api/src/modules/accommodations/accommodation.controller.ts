import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { accommodationService } from './accommodation.service.js';
import type {
  accommodationBody,
  accommodationBookSchema,
  accommodationListQuery,
  accommodationPatch,
} from './accommodation.schema.js';

export const accommodationController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await accommodationService.list(req.query as unknown as z.infer<typeof accommodationListQuery>, req.user));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await accommodationService.get(String(req.params.id)));
  }),
  calendar: handle(async (req, res) => {
    const from = typeof req.query.from === 'string' ? new Date(req.query.from) : undefined;
    const to = typeof req.query.to === 'string' ? new Date(req.query.to) : undefined;
    sendSuccess(res, await accommodationService.calendar(String(req.params.id), from, to));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await accommodationService.create(actor(req).id, req.body as z.infer<typeof accommodationBody>), 201);
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await accommodationService.update(
        user.id,
        user.role,
        String(req.params.id),
        req.body as z.infer<typeof accommodationPatch>,
      ),
    );
  }),
  book: handle(async (req, res) => {
    sendSuccess(
      res,
      await accommodationService.book(
        actor(req).id,
        String(req.params.id),
        req.body as z.infer<typeof accommodationBookSchema>,
      ),
      201,
    );
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await accommodationService.remove(user.id, user.role, String(req.params.id)));
  }),
};
