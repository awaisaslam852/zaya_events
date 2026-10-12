import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { chatService } from './chat.service.js';
import type {
  conversationCreateSchema,
  conversationListQuery,
  messageCreateSchema,
  messageListQuery,
} from './chat.schema.js';

export const chatController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await chatService.list(actor(req).id, req.query as unknown as z.infer<typeof conversationListQuery>));
  }),
  start: handle(async (req, res) => {
    sendSuccess(res, await chatService.start(actor(req).id, req.body as z.infer<typeof conversationCreateSchema>), 201);
  }),
  support: handle(async (req, res) => {
    sendSuccess(res, await chatService.startSupport(actor(req).id), 201);
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await chatService.get(actor(req).id, String(req.params.id)));
  }),
  messages: handle(async (req, res) => {
    sendSuccess(
      res,
      await chatService.messages(
        actor(req).id,
        String(req.params.id),
        req.query as unknown as z.infer<typeof messageListQuery>,
      ),
    );
  }),
  send: handle(async (req, res) => {
    sendSuccess(
      res,
      await chatService.send(actor(req).id, String(req.params.id), req.body as z.infer<typeof messageCreateSchema>),
      201,
    );
  }),
  read: handle(async (req, res) => {
    sendSuccess(res, await chatService.markRead(actor(req).id, String(req.params.id)));
  }),
};
