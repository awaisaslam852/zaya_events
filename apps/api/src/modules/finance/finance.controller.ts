import type { z } from 'zod';
import { actor, handle } from '../../lib/common.js';
import { sendSuccess } from '../../lib/http.js';
import { financeService } from './finance.service.js';
import type { erpExportQuery, invoiceListQuery } from './finance.schema.js';

function toCsv(rows: Array<Record<string, string | number>>): string {
  if (rows.length === 0) {
    return 'invoiceNumber\n';
  }
  const first = rows[0] ?? {};
  const headers = Object.keys(first);
  const escape = (value: string | number) => `"${String(value).replaceAll('"', '""')}"`;
  return [headers.join(','), ...rows.map((row) => headers.map((key) => escape(row[key] ?? '')).join(','))].join('\n');
}

export const financeController = {
  list: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await financeService.list(user.id, user.role, req.query as unknown as z.infer<typeof invoiceListQuery>));
  }),
  get: handle(async (req, res) => {
    const user = actor(req);
    sendSuccess(res, await financeService.get(user.id, user.role, String(req.params.id)));
  }),
  erp: handle(async (req, res) => {
    const query = req.query as unknown as z.infer<typeof erpExportQuery>;
    const rows = await financeService.erpExport(query);
    if (query.format === 'json') {
      sendSuccess(res, { items: rows, system: 'generic-erp', vatRate: financeService.vatRate() });
      return;
    }
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="zaya-erp-invoices.csv"');
    res.status(200).send(toCsv(rows));
  }),
};
