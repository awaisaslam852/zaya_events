import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { honeymoonService } from './honeymoon.service.js';
import type { honeymoonBody, honeymoonInquirySchema, honeymoonListQuery, honeymoonPatch } from './honeymoon.schema.js';

export const honeymoonController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await honeymoonService.list(req.query as unknown as z.infer<typeof honeymoonListQuery>, req.user));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await honeymoonService.get(String(req.params.id)));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await honeymoonService.create(actor(req).id, req.body as z.infer<typeof honeymoonBody>), 201);
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await honeymoonService.update(user.id, user.role, String(req.params.id), req.body as z.infer<typeof honeymoonPatch>),
    );
  }),
  inquire: handle(async (req, res) => {
    sendSuccess(
      res,
      await honeymoonService.inquire(
        actor(req).id,
        String(req.params.id),
        req.body as z.infer<typeof honeymoonInquirySchema>,
      ),
      201,
    );
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await honeymoonService.remove(user.id, user.role, String(req.params.id)));
  }),
};
