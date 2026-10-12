import { Router } from 'express';
import { optionalAuth, requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { accommodationController } from './accommodation.controller.js';
import {
  accommodationBody,
  accommodationBookSchema,
  accommodationListQuery,
  accommodationPatch,
} from './accommodation.schema.js';

export const accommodationsRouter = Router();

/**
 * @openapi
 * /api/v1/accommodations:
 *   get:
 *     tags: [Accommodations]
 */
accommodationsRouter.get('/', optionalAuth, validate({ query: accommodationListQuery }), accommodationController.list);
accommodationsRouter.post(
  '/',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ body: accommodationBody }),
  accommodationController.create,
);
accommodationsRouter.get('/:id', validate({ params: idParamSchema }), accommodationController.get);
accommodationsRouter.get('/:id/availability', validate({ params: idParamSchema }), accommodationController.calendar);
accommodationsRouter.patch(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: accommodationPatch }),
  accommodationController.update,
);
accommodationsRouter.post(
  '/:id/book',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema, body: accommodationBookSchema }),
  accommodationController.book,
);
accommodationsRouter.delete(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  accommodationController.remove,
);
