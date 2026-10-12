import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { reportController } from './report.controller.js';
import { reportQuery } from './report.schema.js';

export const reportsRouter = Router();

/**
 * @openapi
 * /api/v1/reports/overview:
 *   get:
 *     tags: [Reports]
 *     security: [{ bearerAuth: [] }]
 */
reportsRouter.get(
  '/overview',
  requireAuth,
  requireRole('admin'),
  validate({ query: reportQuery }),
  reportController.overview,
);
