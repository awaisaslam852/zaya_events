import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { venueVisitService } from './venue-visit.service.js';
import type {
  visitAssignSchema,
  visitDecisionSchema,
  visitListQuery,
  visitNotesSchema,
  visitRequestSchema,
  visitRescheduleSchema,
} from './venue-visit.schema.js';

export const venueVisitController = {
  list: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueVisitService.list(user.id, user.role, req.query as unknown as z.infer<typeof visitListQuery>));
  }),
  get: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueVisitService.get(user.id, user.role, String(req.params.id)));
  }),
  request: handle(async (req, res) => {
    sendSuccess(res, await venueVisitService.request(actor(req).id, req.body as z.infer<typeof visitRequestSchema>), 201);
  }),
  approve: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueVisitService.approve(user.id, user.role, String(req.params.id)));
  }),
  reschedule: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await venueVisitService.reschedule(
        user.id,
        user.role,
        String(req.params.id),
        req.body as z.infer<typeof visitRescheduleSchema>,
      ),
    );
  }),
  assign: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await venueVisitService.assign(user.id, user.role, String(req.params.id), req.body as z.infer<typeof visitAssignSchema>),
    );
  }),
  notes: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await venueVisitService.notes(user.id, user.role, String(req.params.id), req.body as z.infer<typeof visitNotesSchema>),
    );
  }),
  decide: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await venueVisitService.decide(user.id, user.role, String(req.params.id), req.body as z.infer<typeof visitDecisionSchema>),
    );
  }),
  complete: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueVisitService.complete(user.id, user.role, String(req.params.id)));
  }),
  cancel: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueVisitService.cancel(user.id, user.role, String(req.params.id)));
  }),
};
