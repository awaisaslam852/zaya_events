import type { z } from 'zod';
import { handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { reportService } from './report.service.js';
import type { reportQuery } from './report.schema.js';

export const reportController = {
  overview: handle(async (req, res) => {
    sendSuccess(res, await reportService.overview(req.query as unknown as z.infer<typeof reportQuery>));
  }),
};
