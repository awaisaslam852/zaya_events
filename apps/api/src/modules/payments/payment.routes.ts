import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { paymentController } from './payment.controller.js';
import { paymentCreateSchema, paymentListQuery, refundSchema } from './payment.schema.js';

export const paymentsRouter = Router();

/**
 * @openapi
 * /api/v1/payments:
 *   get:
 *     tags: [Payments]
 *     security: [{ bearerAuth: [] }]
 */
paymentsRouter.get('/', requireAuth, validate({ query: paymentListQuery }), paymentController.list);
paymentsRouter.post('/intent', requireAuth, validate({ body: paymentCreateSchema }), paymentController.intent);
paymentsRouter.get('/:id', requireAuth, validate({ params: idParamSchema }), paymentController.get);
paymentsRouter.post(
  '/:id/confirm',
  requireAuth,
  validate({ params: idParamSchema }),
  paymentController.confirm,
);
paymentsRouter.post(
  '/:id/refund',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: refundSchema }),
  paymentController.refund,
);
