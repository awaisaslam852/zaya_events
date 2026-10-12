import type { z } from 'zod';
import { handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { settingService } from './setting.service.js';
import type { settingBody, settingListQuery, settingPatch } from './setting.schema.js';

export const settingController = {
  list: handle(async (req, res) => {
    sendSuccess(res, { items: await settingService.list(req.query as unknown as z.infer<typeof settingListQuery>) });
  }),
  public: handle(async (_req, res) => {
    sendSuccess(res, await settingService.public());
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await settingService.get(String(req.params.key)));
  }),
  upsert: handle(async (req, res) => {
    sendSuccess(res, await settingService.upsert(req.body as z.infer<typeof settingBody>), 201);
  }),
  update: handle(async (req, res) => {
    sendSuccess(res, await settingService.update(String(req.params.key), req.body as z.infer<typeof settingPatch>));
  }),
  integrations: handle(async (_req, res) => {
    sendSuccess(res, settingService.integrations());
  }),
};
