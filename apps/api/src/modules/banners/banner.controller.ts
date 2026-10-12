import { Role } from '@prisma/client';
import type { z } from 'zod';
import { handle, publicAssetUrl } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { bannerService } from './banner.service.js';
import type { bannerBody, bannerListQuery, bannerPatch } from './banner.schema.js';

function withPublicImage<T extends { imageKey: string }>(req: Parameters<typeof publicAssetUrl>[0], row: T): T {
  return { ...row, imageKey: publicAssetUrl(req, row.imageKey) };
}

export const bannerController = {
  list: handle(async (req, res) => {
    const admin = req.user?.role === Role.ADMIN;
    const data = await bannerService.list(req.query as unknown as z.infer<typeof bannerListQuery>, admin);
    sendSuccess(res, { ...data, items: data.items.map((row) => withPublicImage(req, row)) });
  }),
  create: handle(async (req, res) => {
    sendSuccess(res, withPublicImage(req, await bannerService.create(req.body as z.infer<typeof bannerBody>)), 201);
  }),
  update: handle(async (req, res) => {
    sendSuccess(res, withPublicImage(req, await bannerService.update(String(req.params.id), req.body as z.infer<typeof bannerPatch>)));
  }),
  remove: handle(async (req, res) => {
    sendSuccess(res, await bannerService.remove(String(req.params.id)));
  }),
};
