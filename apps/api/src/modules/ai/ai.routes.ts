import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { aiController } from './ai.controller.js';
import { aiChatSchema, aiEventRefSchema } from './ai.schema.js';

export const aiRouter = Router();

/**
 * @openapi
 * /api/v1/ai/chat:
 *   post:
 *     tags: [AI]
 *     security: [{ bearerAuth: [] }]
 */
aiRouter.post('/chat', requireAuth, requireRole('customer', 'admin'), validate({ body: aiChatSchema }), aiController.chat);
aiRouter.post(
  '/recommendations',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: aiEventRefSchema }),
  aiController.recommendations,
);
aiRouter.post(
  '/checklist',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: aiEventRefSchema }),
  aiController.checklist,
);
