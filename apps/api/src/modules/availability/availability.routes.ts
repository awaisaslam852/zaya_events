import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { availabilityController } from './availability.controller.js';
import { availabilityListQuery, availabilityUpsertSchema } from './availability.schema.js';

export const availabilityRouter = Router();

/**
 * @openapi
 * /api/v1/availability:
 *   get:
 *     tags: [Availability]
 *     security: [{ bearerAuth: [] }]
 */
availabilityRouter.get('/', requireAuth, validate({ query: availabilityListQuery }), availabilityController.list);
availabilityRouter.post(
  '/',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ body: availabilityUpsertSchema }),
  availabilityController.create,
);
availabilityRouter.patch(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: availabilityUpsertSchema }),
  availabilityController.update,
);
availabilityRouter.delete(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  availabilityController.remove,
);
