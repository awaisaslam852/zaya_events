import { sendSuccess } from '../../lib/http.js';
import { actor, handle } from '../../lib/common.js';
import { notificationService } from './notification.service.js';
import type { z } from 'zod';
import type { broadcastSchema, notificationListQuery, registerDeviceSchema } from './notification.schema.js';

export const notificationController = {
  list: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof notificationListQuery>;
    sendSuccess(res, await notificationService.list(actor(req).id, query));
  }),
  markRead: handle(async (req, res) => {
    sendSuccess(res, await notificationService.markRead(actor(req).id, String(req.params.id)));
  }),
  markAllRead: handle(async (req, res) => {
    sendSuccess(res, await notificationService.markAllRead(actor(req).id));
  }),
  registerDevice: handle(async (req, res) => {
    const body = req.body as z.infer<typeof registerDeviceSchema>;
    sendSuccess(res, await notificationService.registerDevice(actor(req).id, body.token, body.platform), 201);
  }),
  history: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof notificationListQuery>;
    sendSuccess(res, await notificationService.adminHistory(query));
  }),
  broadcast: handle(async (req, res) => {
    sendSuccess(res, await notificationService.broadcast(req.body as z.infer<typeof broadcastSchema>), 201);
  }),
};
