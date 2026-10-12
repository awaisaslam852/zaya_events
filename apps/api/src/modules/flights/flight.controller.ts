import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { flightService } from './flight.service.js';
import type { flightBookSchema, flightCancelSchema, flightListQuery } from './flight.schema.js';

export const flightController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await flightService.list(req.query as unknown as z.infer<typeof flightListQuery>));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await flightService.get(String(req.params.id)));
  }),
  book: handle(async (req, res) => {
    sendSuccess(
      res,
      await flightService.book(actor(req).id, String(req.params.id), req.body as z.infer<typeof flightBookSchema>),
      201,
    );
  }),
  cancel: handle(async (req, res) => {
    sendSuccess(
      res,
      await flightService.cancel(actor(req).id, String(req.params.id), req.body as z.infer<typeof flightCancelSchema>),
    );
  }),
};
