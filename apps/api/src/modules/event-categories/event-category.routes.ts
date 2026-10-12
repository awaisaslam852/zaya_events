import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { eventCategoryController } from './event-category.controller.js';
import { eventCategoryBody, eventCategoryListQuery, eventCategoryPatch } from './event-category.schema.js';

export const eventCategoriesRouter = Router();

/**
 * @openapi
 * /api/v1/event-categories:
 *   get:
 *     tags: [EventCategories]
 */
eventCategoriesRouter.get('/', validate({ query: eventCategoryListQuery }), eventCategoryController.list);
eventCategoriesRouter.get('/:id', validate({ params: idParamSchema }), eventCategoryController.get);
eventCategoriesRouter.post(
  '/',
  requireAuth,
  requireRole('admin'),
  validate({ body: eventCategoryBody }),
  eventCategoryController.create,
);
eventCategoriesRouter.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: eventCategoryPatch }),
  eventCategoryController.update,
);
eventCategoriesRouter.post(
  '/:id/enable',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  eventCategoryController.enable,
);
eventCategoriesRouter.post(
  '/:id/disable',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  eventCategoryController.disable,
);
eventCategoriesRouter.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  eventCategoryController.remove,
);
