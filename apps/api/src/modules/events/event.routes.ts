import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { eventController } from './event.controller.js';
import { eventBody, eventListQuery, eventPatch } from './event.schema.js';

export const eventsRouter = Router();

/**
 * @openapi
 * /api/v1/events:
 *   get:
 *     tags: [Events]
 *     security: [{ bearerAuth: [] }]
 */
eventsRouter.get('/', requireAuth, validate({ query: eventListQuery }), eventController.list);
eventsRouter.get('/:id', requireAuth, validate({ params: idParamSchema }), eventController.get);
eventsRouter.post(
  '/',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: eventBody }),
  eventController.create,
);
eventsRouter.patch(
  '/:id',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema, body: eventPatch }),
  eventController.update,
);
eventsRouter.delete(
  '/:id',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema }),
  eventController.remove,
);
