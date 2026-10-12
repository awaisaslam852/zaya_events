import type { z } from 'zod';
import { handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { eventCategoryService } from './event-category.service.js';
import type { eventCategoryBody, eventCategoryListQuery, eventCategoryPatch } from './event-category.schema.js';

export const eventCategoryController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.list(req.query as unknown as z.infer<typeof eventCategoryListQuery>));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.get(String(req.params.id)));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.create(req.body as z.infer<typeof eventCategoryBody>), 201);
  }),
  update: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.update(String(req.params.id), req.body as z.infer<typeof eventCategoryPatch>));
  }),
  enable: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.setActive(String(req.params.id), true));
  }),
  disable: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.setActive(String(req.params.id), false));
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await eventCategoryService.remove(String(req.params.id)));
  }),
};
