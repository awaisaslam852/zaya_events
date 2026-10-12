import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { crmController } from './crm.controller.js';
import {
  crmFollowUpBody,
  crmFollowUpPatch,
  crmInteractionBody,
  crmNoteBody,
  crmSubjectQuery,
} from './crm.schema.js';

export const crmRouter = Router();

/**
 * @openapi
 * /api/v1/crm/timeline:
 *   get:
 *     tags: [CRM]
 *     security: [{ bearerAuth: [] }]
 */
crmRouter.get('/timeline', requireAuth, requireRole('admin'), validate({ query: crmSubjectQuery }), crmController.timeline);
crmRouter.post('/notes', requireAuth, requireRole('admin'), validate({ body: crmNoteBody }), crmController.note);
crmRouter.post(
  '/interactions',
  requireAuth,
  requireRole('admin'),
  validate({ body: crmInteractionBody }),
  crmController.interaction,
);
crmRouter.post(
  '/follow-ups',
  requireAuth,
  requireRole('admin'),
  validate({ body: crmFollowUpBody }),
  crmController.followUp,
);
crmRouter.patch(
  '/follow-ups/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: crmFollowUpPatch }),
  crmController.patchFollowUp,
);
