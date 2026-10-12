import { InvoiceStatus, PaymentStatus, Role, type Prisma } from '@prisma/client';
import { env } from '../../config/env.js';
import { ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { prisma } from '../../lib/prisma.js';
import type { z } from 'zod';
import type { erpExportQuery, invoiceListQuery } from './finance.schema.js';

function invoiceNumber(): string {
  const now = new Date();
  const stamp = `${now.getUTCFullYear()}${String(now.getUTCMonth() + 1).padStart(2, '0')}`;
  return `INV-${stamp}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
}

export const financeService = {
  vatRate(): number {
    return env.VAT_RATE;
  },

  async issueForPayment(paymentId: string) {
    const payment = await prisma.payment.findFirst({
      where: { id: paymentId, ...notDeleted },
      include: { booking: { include: { customer: true, vendor: true } }, invoice: true },
    });
    if (!payment) {
      throw new NotFoundError('Payment not found');
    }
    if (payment.invoice) {
      return payment.invoice;
    }
    const total = Number(payment.amount);
    const rate = this.vatRate();
    const subtotal = Math.round((total / (1 + rate / 100)) * 100) / 100;
    const vatAmount = Math.round((total - subtotal) * 100) / 100;
    return prisma.invoice.create({
      data: {
        invoiceNumber: invoiceNumber(),
        booking: { connect: { id: payment.bookingId } },
        payment: { connect: { id: payment.id } },
        user: { connect: { id: payment.userId } },
        status: payment.status === PaymentStatus.SUCCEEDED ? InvoiceStatus.PAID : InvoiceStatus.ISSUED,
        subtotalAmount: subtotal,
        vatRate: rate,
        vatAmount,
        totalAmount: total,
        currency: payment.currency,
        taxId: payment.booking.vendor?.taxId ?? null,
        lines: [
          {
            description: `${payment.kind} · ${payment.booking.bookingNumber}`,
            amount: subtotal,
            vatAmount,
            total,
          },
        ],
      },
    });
  },

  async list(userId: string, role: Role, query: z.infer<typeof invoiceListQuery>) {
    const { skip, take } = skipTake(query);
    const where: Prisma.InvoiceWhereInput = {
      ...notDeleted,
      ...(query.bookingId ? { bookingId: query.bookingId } : {}),
      ...(query.status ? { status: query.status } : {}),
      ...(query.q ? { invoiceNumber: { contains: query.q, mode: 'insensitive' } } : {}),
      ...(role === Role.ADMIN ? {} : { userId }),
    };
    const [items, total] = await prisma.$transaction([
      prisma.invoice.findMany({
        where,
        include: { booking: { select: { bookingNumber: true, type: true } }, payment: true },
        orderBy: { issuedAt: 'desc' },
        skip,
        take,
      }),
      prisma.invoice.count({ where }),
    ]);
    return paginated(items, total, query);
  },

  async get(userId: string, role: Role, id: string) {
    const row = await prisma.invoice.findFirst({
      where: { id, ...notDeleted },
      include: {
        booking: { include: { customer: true, vendor: true } },
        payment: true,
        user: { select: { id: true, firstName: true, lastName: true, email: true, phone: true } },
      },
    });
    if (!row) {
      throw new NotFoundError('Invoice not found');
    }
    if (role !== Role.ADMIN && row.userId !== userId) {
      throw new ForbiddenError();
    }
    return row;
  },

  async erpExport(query: z.infer<typeof erpExportQuery>) {
    const rows = await prisma.invoice.findMany({
      where: {
        ...notDeleted,
        ...(query.from || query.to
          ? {
              issuedAt: {
                ...(query.from ? { gte: query.from } : {}),
                ...(query.to ? { lte: query.to } : {}),
              },
            }
          : {}),
      },
      include: {
        booking: { select: { bookingNumber: true, type: true } },
        user: { select: { email: true, firstName: true, lastName: true } },
        payment: { select: { providerRef: true, kind: true, status: true } },
      },
      orderBy: { issuedAt: 'asc' },
    });
    await prisma.invoice.updateMany({
      where: { id: { in: rows.map((row) => row.id) } },
      data: { erpExportedAt: new Date() },
    });
    return rows.map((row) => ({
      invoiceNumber: row.invoiceNumber,
      issuedAt: row.issuedAt.toISOString(),
      bookingNumber: row.booking.bookingNumber,
      bookingType: row.booking.type,
      customer: `${row.user.firstName} ${row.user.lastName}`.trim(),
      customerEmail: row.user.email,
      kind: row.payment?.kind ?? '',
      subtotal: Number(row.subtotalAmount),
      vatRate: Number(row.vatRate),
      vatAmount: Number(row.vatAmount),
      total: Number(row.totalAmount),
      currency: row.currency,
      status: row.status,
      taxId: row.taxId ?? '',
      paymentRef: row.payment?.providerRef ?? '',
      accountCode: '4000-EVENTS',
    }));
  },
};
