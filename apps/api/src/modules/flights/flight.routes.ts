import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { flightController } from './flight.controller.js';
import {
  flightBookSchema,
  flightBookingParam,
  flightCancelSchema,
  flightIdParam,
  flightListQuery,
} from './flight.schema.js';

export const flightsRouter = Router();

/**
 * @openapi
 * /api/v1/flights:
 *   get:
 *     tags: [Flights]
 */
flightsRouter.get('/', validate({ query: flightListQuery }), flightController.list);
flightsRouter.post(
  '/bookings/:id/cancel',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: flightBookingParam, body: flightCancelSchema }),
  flightController.cancel,
);
flightsRouter.get('/:id', validate({ params: flightIdParam }), flightController.get);
flightsRouter.post(
  '/:id/book',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ params: flightIdParam, body: flightBookSchema }),
  flightController.book,
);
