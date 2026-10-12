import type { z } from 'zod';
import { handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { serviceCategoryService } from './service-category.service.js';
import type { serviceCategoryBody, serviceCategoryListQuery, serviceCategoryPatch } from './service-category.schema.js';

export const serviceCategoryController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await serviceCategoryService.list(req.query as unknown as z.infer<typeof serviceCategoryListQuery>));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await serviceCategoryService.get(String(req.params.id)));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await serviceCategoryService.create(req.body as z.infer<typeof serviceCategoryBody>), 201);
  }),
  update: handle(async (req, res) => {
    sendSuccess(
      res,
      await serviceCategoryService.update(String(req.params.id), req.body as z.infer<typeof serviceCategoryPatch>),
    );
  }),
  enable: handle(async (req, res) => {
    sendSuccess(res, await serviceCategoryService.setActive(String(req.params.id), true));
  }),
  disable: handle(async (req, res) => {
    sendSuccess(res, await serviceCategoryService.setActive(String(req.params.id), false));
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await serviceCategoryService.remove(String(req.params.id)));
  }),
};
