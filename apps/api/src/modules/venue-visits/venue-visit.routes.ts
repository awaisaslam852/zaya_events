import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { venueVisitController } from './venue-visit.controller.js';
import {
  visitAssignSchema,
  visitDecisionSchema,
  visitListQuery,
  visitNotesSchema,
  visitRequestSchema,
  visitRescheduleSchema,
} from './venue-visit.schema.js';

export const venueVisitsRouter = Router();

/**
 * @openapi
 * /api/v1/venue-visits:
 *   get:
 *     tags: [VenueVisits]
 *     security: [{ bearerAuth: [] }]
 */
venueVisitsRouter.get('/', requireAuth, validate({ query: visitListQuery }), venueVisitController.list);
venueVisitsRouter.post(
  '/',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: visitRequestSchema }),
  venueVisitController.request,
);
venueVisitsRouter.get('/:id', requireAuth, validate({ params: idParamSchema }), venueVisitController.get);
venueVisitsRouter.post(
  '/:id/approve',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  venueVisitController.approve,
);
venueVisitsRouter.post(
  '/:id/reschedule',
  requireAuth,
  requireRole('vendor', 'admin', 'customer'),
  validate({ params: idParamSchema, body: visitRescheduleSchema }),
  venueVisitController.reschedule,
);
venueVisitsRouter.post(
  '/:id/assign',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: visitAssignSchema }),
  venueVisitController.assign,
);
venueVisitsRouter.post(
  '/:id/notes',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: visitNotesSchema }),
  venueVisitController.notes,
);
venueVisitsRouter.post(
  '/:id/decision',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema, body: visitDecisionSchema }),
  venueVisitController.decide,
);
venueVisitsRouter.post(
  '/:id/complete',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  venueVisitController.complete,
);
venueVisitsRouter.post(
  '/:id/cancel',
  requireAuth,
  requireRole('customer', 'vendor', 'admin'),
  validate({ params: idParamSchema }),
  venueVisitController.cancel,
);
