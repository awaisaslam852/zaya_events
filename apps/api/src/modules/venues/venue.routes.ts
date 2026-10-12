import { Router } from 'express';
import { optionalAuth, requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { venueController } from './venue.controller.js';
import { venueBody, venueInquirySchema, venueListQuery, venuePackageBody, venuePatch } from './venue.schema.js';

export const venuesRouter = Router();

/**
 * @openapi
 * /api/v1/venues:
 *   get:
 *     tags: [Venues]
 */
venuesRouter.get('/', optionalAuth, validate({ query: venueListQuery }), venueController.list);
venuesRouter.post('/', requireAuth, requireRole('vendor', 'admin'), validate({ body: venueBody }), venueController.create);
venuesRouter.get('/:id', validate({ params: idParamSchema }), venueController.get);
venuesRouter.get('/:id/availability', validate({ params: idParamSchema }), venueController.calendar);
venuesRouter.patch(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: venuePatch }),
  venueController.update,
);
venuesRouter.post(
  '/:id/packages',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: venuePackageBody }),
  venueController.addPackage,
);
venuesRouter.post(
  '/:id/inquire',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema, body: venueInquirySchema }),
  venueController.inquire,
);
venuesRouter.post(
  '/:id/favorite',
  requireAuth,
  validate({ params: idParamSchema }),
  venueController.favorite,
);
venuesRouter.delete(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  venueController.remove,
);
