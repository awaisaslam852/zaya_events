import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { commissionController } from './commission.controller.js';
import { commissionListQuery, commissionRateBody } from './commission.schema.js';

export const commissionsRouter = Router();

/**
 * @openapi
 * /api/v1/commissions:
 *   get:
 *     tags: [Commissions]
 *     security: [{ bearerAuth: [] }]
 */
commissionsRouter.get('/', requireAuth, requireRole('admin'), validate({ query: commissionListQuery }), commissionController.ledger);
commissionsRouter.get('/rates', requireAuth, requireRole('admin'), commissionController.rates);
commissionsRouter.post(
  '/rates',
  requireAuth,
  requireRole('admin'),
  validate({ body: commissionRateBody }),
  commissionController.createRate,
);
commissionsRouter.patch(
  '/rates/:id',
  requireAuth,
  requireRole('admin'),
  validate({ params: idParamSchema, body: commissionRateBody.partial() }),
  commissionController.updateRate,
);
