import { Router } from 'express';
import { optionalAuth, requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { listingController } from './listing.controller.js';
import { listingBody, listingListQuery, listingPackageBody, listingPackageParams, listingPatch } from './listing.schema.js';

export const listingsRouter = Router();

/**
 * @openapi
 * /api/v1/listings:
 *   get:
 *     tags: [Listings]
 */
listingsRouter.get('/', optionalAuth, validate({ query: listingListQuery }), listingController.list);
listingsRouter.get('/:id', validate({ params: idParamSchema }), listingController.get);
listingsRouter.post(
  '/',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ body: listingBody }),
  listingController.create,
);
listingsRouter.patch(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: listingPatch }),
  listingController.update,
);
listingsRouter.delete(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  listingController.remove,
);
listingsRouter.post(
  '/:id/packages',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: listingPackageBody }),
  listingController.addPackage,
);
listingsRouter.patch(
  '/:id/packages/:packageId',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: listingPackageParams, body: listingPackageBody.partial() }),
  listingController.updatePackage,
);
