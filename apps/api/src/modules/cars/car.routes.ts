import { Router } from 'express';
import { optionalAuth, requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { carController } from './car.controller.js';
import { carBody, carBookSchema, carListQuery, carPatch } from './car.schema.js';

export const carsRouter = Router();

/**
 * @openapi
 * /api/v1/cars:
 *   get:
 *     tags: [Cars]
 */
carsRouter.get('/', optionalAuth, validate({ query: carListQuery }), carController.list);
carsRouter.post('/', requireAuth, requireRole('vendor', 'admin'), validate({ body: carBody }), carController.create);
carsRouter.get('/:id', validate({ params: idParamSchema }), carController.get);
carsRouter.get('/:id/availability', validate({ params: idParamSchema }), carController.calendar);
carsRouter.patch(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: carPatch }),
  carController.update,
);
carsRouter.post(
  '/:id/book',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema, body: carBookSchema }),
  carController.book,
);
carsRouter.delete(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  carController.remove,
);
