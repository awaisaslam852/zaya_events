import { BookingStatus, InvoiceStatus, PaymentKind, PaymentStatus, Role, type Prisma } from '@prisma/client';
import { AppError, ForbiddenError, NotFoundError } from '../../lib/errors.js';
import { notDeleted, paginated, skipTake } from '../../lib/common.js';
import { paymentGateway } from '../../integrations/payments/stripe.provider.js';
import { notificationService } from '../notifications/notification.service.js';
import { bookingService } from '../bookings/booking.service.js';
import { financeService } from '../finance/finance.service.js';
import { prisma } from '../../lib/prisma.js';
import { paymentRepository } from './payment.repository.js';
import type { z } from 'zod';
import type { paymentCreateSchema, paymentListQuery } from './payment.schema.js';

export const paymentService = {
  async list(userId: string, role: Role, query: z.infer<typeof paymentListQuery>) {
    const { skip, take } = skipTake(query);
    const where: Prisma.PaymentWhereInput = {
      ...notDeleted,
      ...(query.bookingId ? { bookingId: query.bookingId } : {}),
      ...(query.q ? { booking: { bookingNumber: { contains: query.q, mode: 'insensitive' } } } : {}),
      ...(role === Role.ADMIN ? {} : { userId }),
    };
    const [items, total] = await paymentRepository.list(where, skip, take);
    return paginated(items, total, query);
  },

  async get(userId: string, role: Role, id: string) {
    const payment = await paymentRepository.findById(id);
    if (!payment) {
      throw new NotFoundError('Payment not found');
    }
    if (role !== Role.ADMIN && payment.userId !== userId) {
      throw new ForbiddenError();
    }
    return payment;
  },

  async createIntent(userId: string, role: Role, input: z.infer<typeof paymentCreateSchema>) {
    if (input.kind === PaymentKind.REFUND) {
      throw new AppError(422, 'INVALID_KIND', 'Use the refund endpoint for refunds');
    }
    const booking = await bookingService.get(userId, role, input.bookingId);
    const amount = input.kind === PaymentKind.DEPOSIT ? Number(booking.depositAmount) : Number(booking.balanceAmount);
    if (amount <= 0) {
      throw new AppError(422, 'INVALID_AMOUNT', 'Nothing to charge for this payment kind');
    }
    const paidSameKind = (booking.payments ?? []).some(
      (row) => row.kind === input.kind && row.status === PaymentStatus.SUCCEEDED,
    );
    if (paidSameKind) {
      throw new AppError(422, 'ALREADY_PAID', 'This installment is already paid');
    }
    const intent = await paymentGateway.createIntent({
      amount,
      currency: booking.currency,
      metadata: { bookingId: booking.id, userId, kind: input.kind },
    });
    const payment = await paymentRepository.create({
      booking: { connect: { id: booking.id } },
      user: { connect: { id: userId } },
      providerRef: intent.providerRef,
      kind: input.kind,
      amount,
      currency: booking.currency,
      status: PaymentStatus.PROCESSING,
      rawPayload: { checkoutUrl: intent.checkoutUrl, mock: intent.mock },
    });
    return {
      payment,
      clientSecret: intent.clientSecret,
      checkoutUrl: intent.checkoutUrl,
      mock: intent.mock,
      publishableKey: intent.mock ? null : process.env.STRIPE_PUBLISHABLE_KEY ?? null,
    };
  },

  async confirm(userId: string, role: Role, id: string) {
    const payment = await this.get(userId, role, id);
    if (payment.status === PaymentStatus.SUCCEEDED) {
      return payment;
    }
    const mock = Boolean((payment.rawPayload as { mock?: boolean } | null)?.mock) || !process.env.STRIPE_SECRET_KEY;
    if (!mock) {
      throw new AppError(422, 'CONFIRM_NOT_ALLOWED', 'Live Stripe payments are confirmed by webhook or Checkout');
    }
    return this.applySuccess(payment.id);
  },

  async refund(userId: string, role: Role, id: string, amount?: number) {
    if (role !== Role.ADMIN) {
      throw new ForbiddenError();
    }
    const payment = await paymentRepository.findById(id);
    if (!payment?.providerRef) {
      throw new NotFoundError('Payment not found');
    }
    const result = await paymentGateway.refund(payment.providerRef, amount);
    const updated = await paymentRepository.update(id, {
      status: amount && amount < Number(payment.amount) ? PaymentStatus.PARTIALLY_REFUNDED : PaymentStatus.REFUNDED,
      rawPayload: { refundId: result.refundId },
    });
    await prisma.invoice.updateMany({
      where: { paymentId: id, deletedAt: null },
      data: { status: InvoiceStatus.VOID },
    });
    await notificationService.notify({
      userId: payment.userId,
      title: { en: 'Refund processed', ar: 'تم الاسترداد' },
      body: { en: 'A refund was issued for your booking.', ar: 'تم إصدار استرداد لحجزك.' },
      data: { type: 'payment_refund', paymentId: id },
    });
    return updated;
  },

  async handleWebhook(raw: Buffer, signature: string) {
    const event = await paymentGateway.parseWebhook(raw, signature);
    const payment = await paymentRepository.findByProviderRef(event.providerRef);
    if (!payment) {
      return { ignored: true };
    }
    if (event.status === 'SUCCEEDED') {
      await this.applySuccess(payment.id);
      return { handled: true };
    }
    await paymentRepository.update(payment.id, { status: event.status as PaymentStatus, rawPayload: event });
    return { handled: true };
  },

  async applySuccess(paymentId: string) {
    const payment = await paymentRepository.findById(paymentId);
    if (!payment) {
      throw new NotFoundError('Payment not found');
    }
    if (payment.status !== PaymentStatus.SUCCEEDED) {
      await paymentRepository.update(payment.id, { status: PaymentStatus.SUCCEEDED });
    }
    const invoice = await financeService.issueForPayment(payment.id);
    const booking = await prisma.booking.findFirst({
      where: { id: payment.bookingId },
      include: { payments: { where: { status: PaymentStatus.SUCCEEDED, deletedAt: null } } },
    });
    if (booking) {
      const paid = booking.payments.reduce((sum, row) => sum + Number(row.amount), 0);
      const total = Number(booking.totalAmount);
      if (paid >= total - 0.01 && booking.status !== BookingStatus.PAID && booking.status !== BookingStatus.COMPLETED) {
        await prisma.booking.update({
          where: { id: booking.id },
          data: {
            status: BookingStatus.PAID,
            statusHistory: {
              create: { fromStatus: booking.status, toStatus: BookingStatus.PAID, reason: 'payment_captured' },
            },
          },
        });
      }
    }
    await notificationService.notify({
      userId: payment.userId,
      title: { en: 'Payment received', ar: 'تم استلام الدفع' },
      body: { en: `Invoice ${invoice.invoiceNumber} is ready.`, ar: `الفاتورة ${invoice.invoiceNumber} جاهزة.` },
      data: { type: 'payment_succeeded', paymentId: payment.id, bookingId: payment.bookingId, invoiceId: invoice.id },
    });
    return paymentRepository.findById(payment.id);
  },
};
