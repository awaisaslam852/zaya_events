import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { chatController } from './chat.controller.js';
import {
  conversationCreateSchema,
  conversationListQuery,
  messageCreateSchema,
  messageListQuery,
} from './chat.schema.js';

export const chatRouter = Router();

/**
 * @openapi
 * /api/v1/chat/conversations:
 *   get:
 *     tags: [Chat]
 *     security: [{ bearerAuth: [] }]
 */
chatRouter.get('/conversations', requireAuth, validate({ query: conversationListQuery }), chatController.list);
chatRouter.post('/conversations/support', requireAuth, chatController.support);
chatRouter.post(
  '/conversations',
  requireAuth,
  validate({ body: conversationCreateSchema }),
  chatController.start,
);
chatRouter.get('/conversations/:id', requireAuth, validate({ params: idParamSchema }), chatController.get);
chatRouter.get(
  '/conversations/:id/messages',
  requireAuth,
  validate({ params: idParamSchema, query: messageListQuery }),
  chatController.messages,
);
chatRouter.post(
  '/conversations/:id/messages',
  requireAuth,
  validate({ params: idParamSchema, body: messageCreateSchema }),
  chatController.send,
);
chatRouter.post(
  '/conversations/:id/read',
  requireAuth,
  validate({ params: idParamSchema }),
  chatController.read,
);
