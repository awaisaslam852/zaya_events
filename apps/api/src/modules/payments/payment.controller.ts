import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { paymentService } from './payment.service.js';
import type { paymentCreateSchema, paymentListQuery, refundSchema } from './payment.schema.js';

export const paymentController = {
  list: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await paymentService.list(user.id, user.role, req.query as unknown as z.infer<typeof paymentListQuery>));
  }),
  get: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await paymentService.get(user.id, user.role, String(req.params.id)));
  }),
  intent: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await paymentService.createIntent(user.id, user.role, req.body as z.infer<typeof paymentCreateSchema>), 201);
  }),
  confirm: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await paymentService.confirm(user.id, user.role, String(req.params.id)));
  }),
  refund: handle(async (req, res) => {
    const user = actor(req);
    const body = req.body as z.infer<typeof refundSchema>;
    sendSuccess(res, await paymentService.refund(user.id, user.role, String(req.params.id), body.amount));
  }),
  webhook: handle(async (req, res) => {
    const signature = req.header('stripe-signature');
    if (!signature) {
      res.status(400).json({ success: false, error: { code: 'MISSING_SIGNATURE', message: 'stripe-signature required' } });
      return;
    }
    const raw = Buffer.isBuffer(req.body) ? req.body : Buffer.from(JSON.stringify(req.body));
    sendSuccess(res, await paymentService.handleWebhook(raw, signature));
  }),
};
