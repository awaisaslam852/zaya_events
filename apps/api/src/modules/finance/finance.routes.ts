import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { financeController } from './finance.controller.js';
import { erpExportQuery, invoiceListQuery } from './finance.schema.js';

export const invoicesRouter = Router();
export const financeRouter = Router();

/**
 * @openapi
 * /api/v1/invoices:
 *   get:
 *     tags: [Finance]
 *     security: [{ bearerAuth: [] }]
 */
invoicesRouter.get('/', requireAuth, validate({ query: invoiceListQuery }), financeController.list);
invoicesRouter.get('/:id', requireAuth, validate({ params: idParamSchema }), financeController.get);

financeRouter.get(
  '/erp',
  requireAuth,
  requireRole('admin'),
  validate({ query: erpExportQuery }),
  financeController.erp,
);
