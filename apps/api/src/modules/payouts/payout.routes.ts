import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { payoutController } from './payout.controller.js';
import { payoutCreateSchema, payoutListQuery } from './payout.schema.js';

export const payoutsRouter = Router();

/**
 * @openapi
 * /api/v1/payouts:
 *   get:
 *     tags: [Payouts]
 *     security: [{ bearerAuth: [] }]
 */
payoutsRouter.get('/', requireAuth, requireRole('admin'), validate({ query: payoutListQuery }), payoutController.list);
payoutsRouter.post('/', requireAuth, requireRole('admin'), validate({ body: payoutCreateSchema }), payoutController.create);
payoutsRouter.post(
  '/:id/paid',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema }),
  payoutController.markPaid,
);
