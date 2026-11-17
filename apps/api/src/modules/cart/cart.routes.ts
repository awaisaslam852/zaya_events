import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { cartController } from './cart.controller.js';
import { cartAddSchema, cartCheckoutSchema } from './cart.schema.js';

export const cartRouter = Router();

/**
 * @openapi
 * /api/v1/cart:
 *   get:
 *     tags: [Cart]
 *     security: [{ bearerAuth: [] }]
 */
cartRouter.get('/', requireAuth, requireRole('customer', 'admin'), cartController.list);
cartRouter.post(
  '/',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: cartAddSchema }),
  cartController.add,
);
cartRouter.post(
  '/checkout',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: cartCheckoutSchema }),
  cartController.checkout,
);
cartRouter.delete('/', requireAuth, requireRole('customer', 'admin'), cartController.clear);
cartRouter.delete(
  '/:id',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema }),
  cartController.remove,
);
