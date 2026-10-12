import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { vendorService } from './vendor.service.js';
import type {
  vendorAdminCreateSchema,
  vendorApplySchema,
  vendorDecisionSchema,
  vendorListQuery,
  vendorProfilePatch,
} from './vendor.schema.js';

export const vendorController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await vendorService.list(actor(req).role, req.query as unknown as z.infer<typeof vendorListQuery>));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await vendorService.createByAdmin(req.body as z.infer<typeof vendorAdminCreateSchema>), 201);
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await vendorService.get(String(req.params.id)));
  }),
  me: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await vendorService.me(user.id, user.role));
  }),
  earnings: handle(async (req, res) => {
    sendSuccess(res, await vendorService.earnings(actor(req).id));
  }),
  reviews: handle(async (req, res) => {
    sendSuccess(res, await vendorService.reviews(actor(req).id));
  }),
  apply: handle(async (req, res) => {
    sendSuccess(res, await vendorService.apply(actor(req).id, req.body as z.infer<typeof vendorApplySchema>), 201);
  }),
  updateMe: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await vendorService.updateProfile(user.id, user.role, undefined, req.body as z.infer<typeof vendorProfilePatch>));
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await vendorService.updateProfile(user.id, user.role, String(req.params.id), req.body as z.infer<typeof vendorProfilePatch>),
    );
  }),
  approve: handle(async (req, res) => {
    sendSuccess(res, await vendorService.approve(String(req.params.id)));
  }),
  reject: handle(async (req, res) => {
    const body = req.body as z.infer<typeof vendorDecisionSchema>;
    sendSuccess(res, await vendorService.reject(String(req.params.id), body.reason));
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await vendorService.remove(String(req.params.id)));
  }),
};
