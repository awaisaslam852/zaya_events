import { InvoiceStatus } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const invoiceListQuery = paginationQuerySchema.extend({
  bookingId: z.string().uuid().optional(),
  status: z.nativeEnum(InvoiceStatus).optional(),
  q: z.string().optional(),
});

export const erpExportQuery = z.object({
  format: z.enum(['json', 'csv']).default('csv'),
  from: z.coerce.date().optional(),
  to: z.coerce.date().optional(),
});
