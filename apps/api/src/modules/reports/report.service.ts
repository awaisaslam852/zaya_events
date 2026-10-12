import { reportRepository } from './report.repository.js';
import type { z } from 'zod';
import type { reportQuery } from './report.schema.js';

export const reportService = {
  overview(query: z.infer<typeof reportQuery>) {
    return reportRepository.aggregates(query.from, query.to);
  },
};
