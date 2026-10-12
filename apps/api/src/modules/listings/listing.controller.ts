import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { listingService } from './listing.service.js';
import type { listingBody, listingListQuery, listingPackageBody, listingPatch } from './listing.schema.js';

export const listingController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await listingService.list(req.query as unknown as z.infer<typeof listingListQuery>, req.user));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await listingService.get(String(req.params.id)));
  }),
  create: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await listingService.create(user.id, user.role, req.body as z.infer<typeof listingBody>), 201);
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await listingService.update(user.id, user.role, String(req.params.id), req.body as z.infer<typeof listingPatch>),
    );
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await listingService.remove(user.id, user.role, String(req.params.id)));
  }),
  addPackage: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await listingService.addPackage(user.id, user.role, String(req.params.id), req.body as z.infer<typeof listingPackageBody>),
      201,
    );
  }),
  updatePackage: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await listingService.updatePackage(
        user.id,
        user.role,
        String(req.params.id),
        String(req.params.packageId),
        req.body as Partial<z.infer<typeof listingPackageBody>>,
      ),
    );
  }),
};
