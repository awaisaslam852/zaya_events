import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { venueService } from './venue.service.js';
import type { venueBody, venueInquirySchema, venueListQuery, venuePackageBody, venuePatch } from './venue.schema.js';

export const venueController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await venueService.list(req.query as unknown as z.infer<typeof venueListQuery>, req.user));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await venueService.get(String(req.params.id)));
  }),
  calendar: handle(async (req, res) => {
    const from = typeof req.query.from === 'string' ? new Date(req.query.from) : undefined;
    const to = typeof req.query.to === 'string' ? new Date(req.query.to) : undefined;
    sendSuccess(res, await venueService.calendar(String(req.params.id), from, to));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await venueService.create(actor(req).id, req.body as z.infer<typeof venueBody>), 201);
  }),
  update: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueService.update(user.id, user.role, String(req.params.id), req.body as z.infer<typeof venuePatch>));
  }),
  addPackage: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await venueService.addPackage(user.id, user.role, String(req.params.id), req.body as z.infer<typeof venuePackageBody>),
      201,
    );
  }),
  inquire: handle(async (req, res) => {
    sendSuccess(
      res,
      await venueService.inquire(actor(req).id, String(req.params.id), req.body as z.infer<typeof venueInquirySchema>),
      201,
    );
  }),
  favorite: handle(async (req, res) => {
    sendSuccess(res, await venueService.toggleFavorite(actor(req).id, String(req.params.id)));
  }),
  remove: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await venueService.remove(user.id, user.role, String(req.params.id)));
  }),
};
