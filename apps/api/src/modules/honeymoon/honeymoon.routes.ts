import { Router } from 'express';
import { optionalAuth, requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { honeymoonController } from './honeymoon.controller.js';
import { honeymoonBody, honeymoonInquirySchema, honeymoonListQuery, honeymoonPatch } from './honeymoon.schema.js';

export const honeymoonRouter = Router();

/**
 * @openapi
 * /api/v1/honeymoon:
 *   get:
 *     tags: [Honeymoon]
 */
honeymoonRouter.get('/', optionalAuth, validate({ query: honeymoonListQuery }), honeymoonController.list);
honeymoonRouter.post(
  '/',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ body: honeymoonBody }),
  honeymoonController.create,
);
honeymoonRouter.get('/:id', validate({ params: idParamSchema }), honeymoonController.get);
honeymoonRouter.patch(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: honeymoonPatch }),
  honeymoonController.update,
);
honeymoonRouter.post(
  '/:id/inquire',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: idParamSchema, body: honeymoonInquirySchema }),
  honeymoonController.inquire,
);
honeymoonRouter.delete(
  '/:id',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema }),
  honeymoonController.remove,
);
