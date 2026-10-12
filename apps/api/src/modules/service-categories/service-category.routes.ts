import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { serviceCategoryController } from './service-category.controller.js';
import { serviceCategoryBody, serviceCategoryListQuery, serviceCategoryPatch } from './service-category.schema.js';

export const serviceCategoriesRouter = Router();

/**
 * @openapi
 * /api/v1/service-categories:
 *   get:
 *     tags: [ServiceCategories]
 */
serviceCategoriesRouter.get('/', validate({ query: serviceCategoryListQuery }), serviceCategoryController.list);
serviceCategoriesRouter.get('/:id', validate({ params: idParamSchema }), serviceCategoryController.get);
serviceCategoriesRouter.post(
  '/',
  requireAuth,
  requireRole('admin'),
  validate({ body: serviceCategoryBody }),
  serviceCategoryController.create,
);
serviceCategoriesRouter.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: serviceCategoryPatch }),
  serviceCategoryController.update,
);
serviceCategoriesRouter.post(
  '/:id/enable',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  serviceCategoryController.enable,
);
serviceCategoriesRouter.post(
  '/:id/disable',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  serviceCategoryController.disable,
);
serviceCategoriesRouter.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  serviceCategoryController.remove,
);
