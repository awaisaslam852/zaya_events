import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { callService } from './call.service.js';
import type { callHistoryQuery, callInitiateSchema } from './call.schema.js';

export const callController = {
  initiate: handle(async (req, res) => {
    sendSuccess(res, await callService.initiate(actor(req).id, req.body as z.infer<typeof callInitiateSchema>), 201);
  }),
  accept: handle(async (req, res) => {
    sendSuccess(res, await callService.accept(actor(req).id, String(req.params.id)));
  }),
  reject: handle(async (req, res) => {
    sendSuccess(res, await callService.reject(actor(req).id, String(req.params.id)));
  }),
  end: handle(async (req, res) => {
    sendSuccess(res, await callService.end(actor(req).id, String(req.params.id)));
  }),
  token: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await callService.token(user.id, user.role, String(req.params.id)));
  }),
  history: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await callService.history(user.id, user.role, req.query as unknown as z.infer<typeof callHistoryQuery>),
    );
  }),
};
