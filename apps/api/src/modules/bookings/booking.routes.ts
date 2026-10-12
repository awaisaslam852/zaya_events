import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { bookingController } from './booking.controller.js';
import { bookingCreateSchema, bookingListQuery, bookingPatchSchema, bookingTransitionSchema } from './booking.schema.js';

export const bookingsRouter = Router();

/**
 * @openapi
 * /api/v1/bookings:
 *   get:
 *     tags: [Bookings]
 *     security: [{ bearerAuth: [] }]
 */
bookingsRouter.get('/', requireAuth, validate({ query: bookingListQuery }), bookingController.list);
bookingsRouter.post(
  '/',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: bookingCreateSchema }),
  bookingController.create,
);
bookingsRouter.post(
  '/inquire',
  requireAuth,
  requireRole('customer', 'admin'),
  validate({ body: bookingCreateSchema }),
  bookingController.inquire,
);
bookingsRouter.get('/:id', requireAuth, validate({ params: idParamSchema }), bookingController.get);
bookingsRouter.patch(
  '/:id',
  requireAuth,
  requireRole('customer', 'admin', 'vendor'),
  validate({ params: idParamSchema, body: bookingPatchSchema }),
  bookingController.patch,
);
bookingsRouter.post(
  '/:id/under-review',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: bookingTransitionSchema }),
  bookingController.underReview,
);
bookingsRouter.post(
  '/:id/confirm',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: bookingTransitionSchema }),
  bookingController.confirm,
);
bookingsRouter.post(
  '/:id/complete',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: bookingTransitionSchema }),
  bookingController.complete,
);
bookingsRouter.post(
  '/:id/cancel',
  requireAuth,
  validate({ params: idParamSchema, body: bookingTransitionSchema }),
  bookingController.cancel,
);
bookingsRouter.post(
  '/:id/reject',
  requireAuth,
  requireRole('vendor', 'admin'),
  validate({ params: idParamSchema, body: bookingTransitionSchema }),
  bookingController.reject,
);
