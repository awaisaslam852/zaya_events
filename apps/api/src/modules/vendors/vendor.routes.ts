import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { vendorController } from './vendor.controller.js';
import {
  vendorAdminCreateSchema,
  vendorApplySchema,
  vendorDecisionSchema,
  vendorListQuery,
  vendorProfilePatch,
} from './vendor.schema.js';

export const vendorsRouter = Router();

/**
 * @openapi
 * /api/v1/vendors:
 *   get:
 *     tags: [Vendors]
 *     security: [{ bearerAuth: [] }]
 */
vendorsRouter.get('/', requireAuth, validate({ query: vendorListQuery }), vendorController.list);
vendorsRouter.post(
  '/',
  requireAuth,
  requireRole('admin'),
  validate({ body: vendorAdminCreateSchema }),
  vendorController.create,
);
vendorsRouter.get('/me', requireAuth, requireRole('vendor', 'admin'), vendorController.me);
vendorsRouter.get('/me/earnings', requireAuth, requireRole('vendor', 'admin'), vendorController.earnings);
vendorsRouter.get('/me/reviews', requireAuth, requireRole('vendor', 'admin'), vendorController.reviews);
vendorsRouter.patch(
  '/me',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ body: vendorProfilePatch }),
  vendorController.updateMe,
);
vendorsRouter.post(
  '/apply',
  requireAuth,
  requireRole('vendor', 'customer'),
  validate({ body: vendorApplySchema }),
  vendorController.apply,
);
vendorsRouter.get('/:id', requireAuth, validate({ params: idParamSchema }), vendorController.get);
vendorsRouter.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: vendorProfilePatch }),
  vendorController.update,
);
vendorsRouter.post(
  '/:id/approve',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  vendorController.approve,
);
vendorsRouter.post(
  '/:id/reject',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: vendorDecisionSchema }),
  vendorController.reject,
);
vendorsRouter.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  vendorController.remove,
);
