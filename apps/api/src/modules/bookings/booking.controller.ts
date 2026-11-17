import { BookingStatus } from '@prisma/client';
import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { bookingService } from './booking.service.js';
import type { bookingCreateSchema, bookingListQuery, bookingPatchSchema, bookingTransitionSchema } from './booking.schema.js';

export const bookingController = {
  list: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await bookingService.list(user.id, user.role, req.query as unknown as z.infer<typeof bookingListQuery>, user));
  }),
  get: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await bookingService.get(user.id, user.role, String(req.params.id), user));
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, await bookingService.create(actor(req).id, req.body as z.infer<typeof bookingCreateSchema>), 201);
  }),
  inquire: handle(async (req, res) => {
    sendSuccess(res, await bookingService.create(actor(req).id, req.body as z.infer<typeof bookingCreateSchema>, true), 201);
  }),
  patch: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(
      res,
      await bookingService.modify(user.id, user.role, String(req.params.id), req.body as z.infer<typeof bookingPatchSchema>, user),
    );
  }),
  underReview: handle(async (req, res) => {
    const user = actor(req);
    const body = req.body as z.infer<typeof bookingTransitionSchema>;
    sendSuccess(res, await bookingService.transition(user.id, user.role, String(req.params.id), BookingStatus.UNDER_REVIEW, body.reason, user));
  }),
  confirm: handle(async (req, res) => {
    const user = actor(req);
    const body = req.body as z.infer<typeof bookingTransitionSchema>;
    sendSuccess(res, await bookingService.transition(user.id, user.role, String(req.params.id), BookingStatus.CONFIRMED, body.reason, user));
  }),
  complete: handle(async (req, res) => {
    const user = actor(req);
    const body = req.body as z.infer<typeof bookingTransitionSchema>;
    sendSuccess(res, await bookingService.transition(user.id, user.role, String(req.params.id), BookingStatus.COMPLETED, body.reason, user));
  }),
  cancel: handle(async (req, res) => {
    const user = actor(req);
    const body = req.body as z.infer<typeof bookingTransitionSchema>;
    sendSuccess(res, await bookingService.transition(user.id, user.role, String(req.params.id), BookingStatus.CANCELLED, body.reason, user));
  }),
  reject: handle(async (req, res) => {
    const user = actor(req);
    const body = req.body as z.infer<typeof bookingTransitionSchema>;
    sendSuccess(res, await bookingService.transition(user.id, user.role, String(req.params.id), BookingStatus.REJECTED, body.reason, user));
  }),
};
