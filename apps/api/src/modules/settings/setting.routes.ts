import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole, requireSuperAdmin } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { settingController } from './setting.controller.js';
import { settingBody, settingListQuery, settingPatch, settingPublicQuery } from './setting.schema.js';

export const settingsRouter = Router();

/**
 * @openapi
 * /api/v1/settings:
 *   get:
 *     tags: [Settings]
 *     security: [{ bearerAuth: [] }]
 */
settingsRouter.get(
  '/',
  requireAuth,
  requireRole('admin'),
  validate({ query: settingListQuery }),
  settingController.list,
);
settingsRouter.get('/public', validate({ query: settingPublicQuery }), settingController.public);
settingsRouter.get('/integrations', requireAuth, requireRole('admin'), settingController.integrations);
settingsRouter.post(
  '/',
  requireAuth,
  requireRole('admin'),
  requireSuperAdmin,
  validate({ body: settingBody }),
  settingController.upsert,
);
settingsRouter.get(
  '/:key',
  requireAuth,
  requireRole('admin'),
  validate({ params: z.object({ key: z.string().min(1) }) }),
  settingController.get,
);
settingsRouter.patch(
  '/:key',
  requireAuth,
  requireRole('admin'),
  requireSuperAdmin,
  validate({ params: z.object({ key: z.string().min(1) }), body: settingPatch }),
  settingController.update,
);
