import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { cartService } from './cart.service.js';
import type { cartAddSchema, cartCheckoutSchema } from './cart.schema.js';

export const cartController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await cartService.list(actor(req).id));
  }),
  add: handle(async (req, res) => {
    sendSuccess(res, await cartService.add(actor(req).id, req.body as z.infer<typeof cartAddSchema>), 201);
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await cartService.remove(actor(req).id, String(req.params.id)));
  }),
  clear: handle(async (req, res) => {
    sendSuccess(res, await cartService.clear(actor(req).id));
  }),
  checkout: handle(async (req, res) => {
    sendSuccess(res, await cartService.checkout(actor(req).id, req.body as z.infer<typeof cartCheckoutSchema>));
  }),
};
