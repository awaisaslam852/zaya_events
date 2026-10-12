import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { validate } from '../../middleware/validate.js';
import { idParamSchema } from '../../lib/common.js';
import { callController } from './call.controller.js';
import { callHistoryQuery, callInitiateSchema } from './call.schema.js';

export const callsRouter = Router();

/**
 * @openapi
 * /api/v1/calls/initiate:
 *   post:
 *     tags: [Calls]
 *     security: [{ bearerAuth: [] }]
 */
callsRouter.post('/initiate', requireAuth, validate({ body: callInitiateSchema }), callController.initiate);
callsRouter.get('/history', requireAuth, validate({ query: callHistoryQuery }), callController.history);
callsRouter.post('/:id/accept', requireAuth, validate({ params: idParamSchema }), callController.accept);
callsRouter.post('/:id/reject', requireAuth, validate({ params: idParamSchema }), callController.reject);
callsRouter.post('/:id/end', requireAuth, validate({ params: idParamSchema }), callController.end);
callsRouter.get('/:id/token', requireAuth, validate({ params: idParamSchema }), callController.token);
