import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { commissionService } from './commission.service.js';
import type { commissionListQuery, commissionPolicyPatch, commissionRateBody } from './commission.schema.js';

export const commissionController = {
  ledger: handle(async (req, res) => {
    sendSuccess(
      res,
      await commissionService.ledger(req.query as unknown as z.infer<typeof commissionListQuery>, actor(req)),
    );
  }),
  rates: handle(async (_req, res) => {
    sendSuccess(res, { items: await commissionService.rates() });
  }),
  createRate: handle(async (req, res) => {
    sendSuccess(res, await commissionService.createRate(req.body as z.infer<typeof commissionRateBody>), 201);
  }),
  updateRate: handle(async (req, res) => {
    sendSuccess(
      res,
      await commissionService.updateRate(String(req.params.id), req.body as Partial<z.infer<typeof commissionRateBody>>),
    );
  }),
  policies: handle(async (req, res) => {
    sendSuccess(res, { items: await commissionService.listPolicies(actor(req)) });
  }),
  updatePolicy: handle(async (req, res) => {
    sendSuccess(
      res,
      await commissionService.updatePolicy(
        String(req.params.country).toUpperCase(),
        req.body as z.infer<typeof commissionPolicyPatch>,
        actor(req),
      ),
    );
  }),
};
