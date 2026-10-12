import path from 'node:path';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import express, { type Express, type Handler } from 'express';
import helmet from 'helmet';
import { createRequire } from 'node:module';
import { env } from './config/env.js';
import { corsOptions } from './lib/cors.js';
import { logger } from './lib/logger.js';
import { sendSuccess } from './lib/http.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import { apiRateLimiter } from './middleware/rateLimiter.js';
import { requireAuth } from './middleware/auth.js';
import { requireRole } from './middleware/rbac.js';
import { customersRouter } from './modules/customers/customer.routes.js';
import { authRouter } from './modules/auth/auth.routes.js';
import { agoraRouter } from './modules/agora/agora.routes.js';
import { uploadsRouter } from './modules/uploads/upload.routes.js';
import { eventCategoriesRouter } from './modules/event-categories/event-category.routes.js';
import { serviceCategoriesRouter } from './modules/service-categories/service-category.routes.js';
import { eventsRouter } from './modules/events/event.routes.js';
import { venuesRouter } from './modules/venues/venue.routes.js';
import { vendorsRouter } from './modules/vendors/vendor.routes.js';
import { listingsRouter } from './modules/listings/listing.routes.js';
import { availabilityRouter } from './modules/availability/availability.routes.js';
import { bookingsRouter } from './modules/bookings/booking.routes.js';
import { venueVisitsRouter } from './modules/venue-visits/venue-visit.routes.js';
import { carsRouter } from './modules/cars/car.routes.js';
import { accommodationsRouter } from './modules/accommodations/accommodation.routes.js';
import { honeymoonRouter } from './modules/honeymoon/honeymoon.routes.js';
import { favoritesRouter } from './modules/favorites/favorite.routes.js';
import { notificationsRouter } from './modules/notifications/notification.routes.js';
import { chatRouter } from './modules/chat/chat.routes.js';
import { callsRouter } from './modules/calls/call.routes.js';
import { aiRouter } from './modules/ai/ai.routes.js';
import { paymentsRouter } from './modules/payments/payment.routes.js';
import { paymentController } from './modules/payments/payment.controller.js';
import { payoutsRouter } from './modules/payouts/payout.routes.js';
import { commissionsRouter } from './modules/commissions/commission.routes.js';
import { crmRouter } from './modules/crm/crm.routes.js';
import { bannersRouter } from './modules/banners/banner.routes.js';
import { settingsRouter } from './modules/settings/setting.routes.js';
import { reportsRouter } from './modules/reports/report.routes.js';
import { flightsRouter } from './modules/flights/flight.routes.js';
import { hotelsRouter } from './modules/hotels/hotel.routes.js';
import { invoicesRouter, financeRouter } from './modules/finance/finance.routes.js';
import { mapsRouter } from './modules/maps/maps.routes.js';
import { mountSwagger } from './docs/swagger.js';

export function createApp(): Express {
  const app = express();

  app.set('trust proxy', 1);
  app.use(cors(corsOptions));
  app.options('*', cors(corsOptions));
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );
  app.use(cookieParser());
  app.post(
    '/api/v1/payments/webhook',
    express.raw({ type: 'application/json' }),
    paymentController.webhook,
  );
  app.use(express.json({ limit: '2mb' }));
  app.use(express.urlencoded({ extended: true }));
  const require = createRequire(import.meta.url);
  const pinoHttp = require('pino-http') as (opts: { logger: typeof logger }) => Handler;
  app.use(pinoHttp({ logger }));
  app.use(apiRateLimiter);

  const uploadsDir = path.resolve(env.STORAGE_LOCAL_DIR);
  app.use('/uploads', express.static(uploadsDir));

  app.get('/health', (_req, res) => {
    sendSuccess(res, { status: 'ok', service: 'zaya-api' });
  });

  app.get('/api/v1/health', (_req, res) => {
    sendSuccess(res, { status: 'ok', service: 'zaya-api' });
  });

  app.get('/api/v1/admin/health', requireAuth, requireRole('admin'), (_req, res) => {
    sendSuccess(res, { status: 'ok', role: 'admin' });
  });

  mountSwagger(app);

  app.use('/api/v1/customers', customersRouter);
  app.use('/api/v1/auth', authRouter);
  app.use('/api/v1/agora', agoraRouter);
  app.use('/api/v1/uploads', uploadsRouter);
  app.use('/api/v1/event-categories', eventCategoriesRouter);
  app.use('/api/v1/service-categories', serviceCategoriesRouter);
  app.use('/api/v1/events', eventsRouter);
  app.use('/api/v1/venues', venuesRouter);
  app.use('/api/v1/vendors', vendorsRouter);
  app.use('/api/v1/listings', listingsRouter);
  app.use('/api/v1/availability', availabilityRouter);
  app.use('/api/v1/bookings', bookingsRouter);
  app.use('/api/v1/venue-visits', venueVisitsRouter);
  app.use('/api/v1/cars', carsRouter);
  app.use('/api/v1/accommodations', accommodationsRouter);
  app.use('/api/v1/honeymoon', honeymoonRouter);
  app.use('/api/v1/flights', flightsRouter);
  app.use('/api/v1/hotels', hotelsRouter);
  app.use('/api/v1/favorites', favoritesRouter);
  app.use('/api/v1/notifications', notificationsRouter);
  app.use('/api/v1/chat', chatRouter);
  app.use('/api/v1/calls', callsRouter);
  app.use('/api/v1/ai', aiRouter);
  app.get('/api/v1/payments/complete', (_req, res) => {
    res.type('html').send(
      '<!doctype html><html><body style="font-family:sans-serif;padding:2rem"><h1>Zaya Events</h1><p>Payment received. You can return to the app.</p></body></html>',
    );
  });
  app.use('/api/v1/payments', paymentsRouter);
  app.use('/api/v1/invoices', invoicesRouter);
  app.use('/api/v1/finance', financeRouter);
  app.use('/api/v1/maps', mapsRouter);
  app.use('/api/v1/payouts', payoutsRouter);
  app.use('/api/v1/commissions', commissionsRouter);
  app.use('/api/v1/crm', crmRouter);
  app.use('/api/v1/banners', bannersRouter);
  app.use('/api/v1/settings', settingsRouter);
  app.use('/api/v1/reports', reportsRouter);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
