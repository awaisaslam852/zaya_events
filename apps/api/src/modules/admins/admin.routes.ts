import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { requireRole, requireSuperAdmin } from '../../middleware/rbac.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { adminController } from './admin.controller.js';
import { adminCreateSchema, adminListQuery, adminPatchSchema } from './admin.schema.js';

export const adminsRouter = Router();

adminsRouter.use(requireAuth, requireRole('admin'), requireSuperAdmin);

/**
 * @openapi
 * /api/v1/admins:
 *   get:
 *     tags: [Admins]
 *     security: [{ bearerAuth: [] }]
 */
adminsRouter.get('/', validate({ query: adminListQuery }), adminController.list);
adminsRouter.post('/', validate({ body: adminCreateSchema }), adminController.create);
adminsRouter.get('/:id', validate({ params: idParamSchema }), adminController.get);
adminsRouter.patch('/:id', validate({ params: idParamSchema, body: adminPatchSchema }), adminController.update);
adminsRouter.delete('/:id', validate({ params: idParamSchema }), adminController.remove);
