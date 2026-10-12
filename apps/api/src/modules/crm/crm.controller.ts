import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { crmService } from './crm.service.js';
import type { crmFollowUpBody, crmFollowUpPatch, crmInteractionBody, crmNoteBody, crmSubjectQuery } from './crm.schema.js';

export const crmController = {
  timeline: handle(async (req, res) => {
    sendSuccess(res, await crmService.timeline(req.query as unknown as z.infer<typeof crmSubjectQuery>));
  }),
  note: handle(async (req, res) => {
    sendSuccess(res, await crmService.addNote(actor(req).id, req.body as z.infer<typeof crmNoteBody>), 201);
  }),
  interaction: handle(async (req, res) => {
    sendSuccess(res, await crmService.addInteraction(actor(req).id, req.body as z.infer<typeof crmInteractionBody>), 201);
  }),
  followUp: handle(async (req, res) => {
    sendSuccess(res, await crmService.addFollowUp(actor(req).id, req.body as z.infer<typeof crmFollowUpBody>), 201);
  }),
  patchFollowUp: handle(async (req, res) => {
    sendSuccess(res, await crmService.updateFollowUp(String(req.params.id), req.body as z.infer<typeof crmFollowUpPatch>));
  }),
};
