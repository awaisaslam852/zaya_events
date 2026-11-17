import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { adminService } from './admin.service.js';
import type { adminCreateSchema, adminListQuery, adminPatchSchema } from './admin.schema.js';

export const adminController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await adminService.list(req.query as unknown as z.infer<typeof adminListQuery>));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await adminService.get(String(req.params.id)));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await adminService.create(req.body as z.infer<typeof adminCreateSchema>, actor(req).id), 201);
  }),
  update: handle(async (req, res) => {
    sendSuccess(
      res,
      await adminService.update(String(req.params.id), actor(req).id, req.body as z.infer<typeof adminPatchSchema>),
    );
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await adminService.remove(String(req.params.id), actor(req).id));
  }),
};
