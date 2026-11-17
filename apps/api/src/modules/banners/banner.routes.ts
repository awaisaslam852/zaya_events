import { Router } from 'express';
import { optionalAuth, requireAuth } from '../../middleware/auth.js';
import { requireRole, requireSuperAdmin } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { bannerController } from './banner.controller.js';
import { bannerBody, bannerListQuery, bannerPatch } from './banner.schema.js';

export const bannersRouter = Router();

/**
 * @openapi
 * /api/v1/banners:
 *   get:
 *     tags: [Banners]
 */
bannersRouter.get('/', optionalAuth, validate({ query: bannerListQuery }), bannerController.list);
bannersRouter.post(
  '/',
  requireAuth,
  requireRole('admin'),
  requireSuperAdmin,
  validate({ body: bannerBody }),
  bannerController.create,
);
bannersRouter.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  requireSuperAdmin,
  validate({ params: idParamSchema, body: bannerPatch }),
  bannerController.update,
);
bannersRouter.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  requireSuperAdmin,
  validate({ params: idParamSchema }),
  bannerController.remove,
);
