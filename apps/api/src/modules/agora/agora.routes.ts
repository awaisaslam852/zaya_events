import { z } from 'zod';
import type { NextFunction, Request, Response } from 'express';
import { Router } from 'express';
import { sendSuccess } from '../../lib/http.js';
import { requireAuth } from '../../middleware/auth.js';
import { validate } from '../../middleware/validate.js';
import { generateRtcToken } from './agora.service.js';

const rtcTokenSchema = z.object({
  channelName: z.string().min(3).max(64),
  uid: z.number().int().min(1),
  role: z.enum(['PUBLISHER', 'SUBSCRIBER']).default('PUBLISHER'),
  expireSeconds: z.number().int().min(60).max(86400).optional(),
});

async function issueToken(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const body = req.body as z.infer<typeof rtcTokenSchema>;
    const data = generateRtcToken(body.channelName, body.uid, body.role, body.expireSeconds);
    sendSuccess(res, data);
  } catch (error) {
    next(error);
  }
}

export const agoraRouter = Router();

/**
 * @openapi
 * /api/v1/agora/rtc-token:
 *   post:
 *     tags: [Agora]
 *     summary: Issue an RTC token (certificate stays on the server)
 *     security:
 *       - bearerAuth: []
 */
agoraRouter.post('/rtc-token', requireAuth, validate({ body: rtcTokenSchema }), issueToken);
