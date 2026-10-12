import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { hotelController } from './hotel.controller.js';
import {
  hotelBookSchema,
  hotelBookingParam,
  hotelCancelSchema,
  hotelIdParam,
  hotelListQuery,
} from './hotel.schema.js';

export const hotelsRouter = Router();

/**
 * @openapi
 * /api/v1/hotels:
 *   get:
 *     tags: [Hotels]
 */
hotelsRouter.get('/', validate({ query: hotelListQuery }), hotelController.list);
hotelsRouter.post(
  '/bookings/:id/cancel',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: hotelBookingParam, body: hotelCancelSchema }),
  hotelController.cancel,
);
hotelsRouter.get('/:id/rooms', validate({ params: hotelIdParam }), hotelController.rooms);
hotelsRouter.get('/:id', validate({ params: hotelIdParam }), hotelController.get);
hotelsRouter.post(
  '/:id/book',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: hotelIdParam, body: hotelBookSchema }),
  hotelController.book,
);
