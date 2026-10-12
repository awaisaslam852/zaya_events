import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { customerController } from './customer.controller.js';
import { customerCreateSchema, customerListQuery, customerPatchSchema } from './customer.schema.js';

export const customersRouter = Router();

/**
 * @openapi
 * /api/v1/customers:
 *   get:
 *     tags: [Customers]
 *     security: [{ bearerAuth: [] }]
 */
customersRouter.get(
  '/',
  requireAuth,
  requireRole('admin'),
  validate({ query: customerListQuery }),
  customerController.list,
);
customersRouter.post(
  '/',
  requireAuth,
  requireRole('admin'),
  validate({ body: customerCreateSchema }),
  customerController.create,
);
customersRouter.get(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  customerController.get,
);
customersRouter.post(
  '/:id/activate',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  customerController.activate,
);
customersRouter.post(
  '/:id/deactivate',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  customerController.deactivate,
);
customersRouter.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: customerPatchSchema }),
  customerController.update,
);
customersRouter.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  customerController.remove,
);
