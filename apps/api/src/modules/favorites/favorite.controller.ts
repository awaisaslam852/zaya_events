import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { favoriteService } from './favorite.service.js';
import type { favoriteBody, favoriteListQuery } from './favorite.schema.js';

export const favoriteController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await favoriteService.list(actor(req).id, req.query as unknown as z.infer<typeof favoriteListQuery>));
  }),
  add: handle(async (req, res) => {
    sendSuccess(res, await favoriteService.add(actor(req).id, req.body as z.infer<typeof favoriteBody>), 201);
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await favoriteService.remove(actor(req).id, req.body as z.infer<typeof favoriteBody>));
  }),
};
