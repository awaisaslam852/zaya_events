import type { AuthUser } from '../../middleware/auth.js';
import { reportRepository } from './report.repository.js';
import type { z } from 'zod';
import type { reportQuery } from './report.schema.js';

export const reportService = {
  overview(query: z.infer<typeof reportQuery>, actor?: AuthUser) {
    return reportRepository.aggregates(query.from, query.to, actor);
  },
};
