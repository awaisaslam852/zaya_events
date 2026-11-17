import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { customerService } from './customer.service.js';
import type { customerCreateSchema, customerListQuery, customerPatchSchema } from './customer.schema.js';

export const customerController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await customerService.list(req.query as unknown as z.infer<typeof customerListQuery>, actor(req)));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await customerService.get(String(req.params.id), actor(req)));
  }),
  activate: handle(async (req, res) => {
    sendSuccess(res, await customerService.setActive(String(req.params.id), true, actor(req)));
  }),
  deactivate: handle(async (req, res) => {
    sendSuccess(res, await customerService.setActive(String(req.params.id), false, actor(req)));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await customerService.create(req.body as z.infer<typeof customerCreateSchema>, actor(req)), 201);
  }),
  update: handle(async (req, res) => {
    sendSuccess(
      res,
      await customerService.update(String(req.params.id), req.body as z.infer<typeof customerPatchSchema>, actor(req)),
    );
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await customerService.remove(String(req.params.id), actor(req)));
  }),
};
