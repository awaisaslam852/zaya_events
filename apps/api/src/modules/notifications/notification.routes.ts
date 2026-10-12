import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { notificationController } from './notification.controller.js';
import { notificationListQuery, registerDeviceSchema, broadcastSchema } from './notification.schema.js';
import { requireRole } from '../../middleware/rbac.js';
import { paginationQuerySchema } from '../../lib/common.js';

export const notificationsRouter = Router();

/**
 * @openapi
 * /api/v1/notifications:
 *   get:
 *     tags: [Notifications]
 *     security: [{ bearerAuth: [] }]
 */
notificationsRouter.get('/', requireAuth, validate({ query: notificationListQuery }), notificationController.list);
notificationsRouter.get(
  '/admin/history',
  requireAuth,
  requireRole('admin'),
  validate({ query: paginationQuerySchema }),
  notificationController.history,
);
notificationsRouter.post(
  '/broadcast',
  requireAuth,
  requireRole('admin'),
  validate({ body: broadcastSchema }),
  notificationController.broadcast,
);
notificationsRouter.post(
  '/read-all',
  requireAuth,
  notificationController.markAllRead,
);
notificationsRouter.post(
  '/devices',
  requireAuth,
  validate({ body: registerDeviceSchema }),
  notificationController.registerDevice,
);
notificationsRouter.post(
  '/:id/read',
  requireAuth,
  validate({ params: idParamSchema }),
  notificationController.markRead,
);
