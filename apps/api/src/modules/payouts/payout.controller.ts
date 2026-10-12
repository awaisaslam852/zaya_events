import type { z } from 'zod';
import { handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { payoutService } from './payout.service.js';
import type { payoutCreateSchema, payoutListQuery } from './payout.schema.js';

export const payoutController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await payoutService.list(req.query as unknown as z.infer<typeof payoutListQuery>));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await payoutService.create(req.body as z.infer<typeof payoutCreateSchema>), 201);
  }),
  markPaid: handle(async (req, res) => {
    sendSuccess(res, await payoutService.markPaid(String(req.params.id)));
  }),
};
