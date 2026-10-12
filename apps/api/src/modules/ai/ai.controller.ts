import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { aiService } from './ai.service.js';
import type { aiChatSchema, aiEventRefSchema } from './ai.schema.js';

export const aiController = {
  chat: handle(async (req, res) => {
    sendSuccess(res, await aiService.chat(actor(req).id, req.body as z.infer<typeof aiChatSchema>));
  }),
  recommendations: handle(async (req, res) => {
    sendSuccess(res, await aiService.recommendations(actor(req).id, req.body as z.infer<typeof aiEventRefSchema>));
  }),
  checklist: handle(async (req, res) => {
    sendSuccess(res, await aiService.checklist(actor(req).id, req.body as z.infer<typeof aiEventRefSchema>));
  }),
};
