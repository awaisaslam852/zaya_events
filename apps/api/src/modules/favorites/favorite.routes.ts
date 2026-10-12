import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { validate } from '../../middleware/validate.js';
import { favoriteController } from './favorite.controller.js';
import { favoriteBody, favoriteListQuery } from './favorite.schema.js';

export const favoritesRouter = Router();

/**
 * @openapi
 * /api/v1/favorites:
 *   get:
 *     tags: [Favorites]
 *     security: [{ bearerAuth: [] }]
 */
favoritesRouter.get('/', requireAuth, validate({ query: favoriteListQuery }), favoriteController.list);
favoritesRouter.post('/', requireAuth, validate({ body: favoriteBody }), favoriteController.add);
favoritesRouter.delete('/', requireAuth, validate({ body: favoriteBody }), favoriteController.remove);
