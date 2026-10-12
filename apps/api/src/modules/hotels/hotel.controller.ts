import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { hotelService } from './hotel.service.js';
import type { hotelBookSchema, hotelCancelSchema, hotelListQuery } from './hotel.schema.js';

export const hotelController = {
  list: handle(async (req, res) => {
    sendSuccess(res, await hotelService.list(req.query as unknown as z.infer<typeof hotelListQuery>));
  }),
  get: handle(async (req, res) => {
    sendSuccess(res, await hotelService.get(String(req.params.id)));
  }),
  rooms: handle(async (req, res) => {
    sendSuccess(
      res,
      await hotelService.rooms(String(req.params.id), {
        checkIn: typeof req.query.checkIn === 'string' ? req.query.checkIn : undefined,
        checkOut: typeof req.query.checkOut === 'string' ? req.query.checkOut : undefined,
      }),
    );
  }),
  book: handle(async (req, res) => {
    sendSuccess(
      res,
      await hotelService.book(actor(req).id, String(req.params.id), req.body as z.infer<typeof hotelBookSchema>),
      201,
    );
  }),
  cancel: handle(async (req, res) => {
    sendSuccess(
      res,
      await hotelService.cancel(actor(req).id, String(req.params.id), req.body as z.infer<typeof hotelCancelSchema>),
    );
  }),
};
