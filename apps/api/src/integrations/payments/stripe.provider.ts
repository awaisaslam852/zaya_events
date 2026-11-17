import { randomUUID } from 'node:crypto';
import Stripe from 'stripe';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import type { CreateIntentInput, CreateIntentResult, IntentStatus, PaymentGateway } from './payment.provider.js';

function stripe(): Stripe {
  if (!env.STRIPE_SECRET_KEY) {
    throw new AppError(500, 'STRIPE_MISCONFIGURED', 'STRIPE_SECRET_KEY must be set');
  }
  return new Stripe(env.STRIPE_SECRET_KEY);
}

export class MockPaymentGateway implements PaymentGateway {
  async createIntent(input: CreateIntentInput): Promise<CreateIntentResult> {
    const id = `pi_mock_${randomUUID()}`;
    return {
      providerRef: id,
      clientSecret: `mock_secret_${id}`,
      mock: true,
    };
  }

  async intentStatus(_providerRef: string): Promise<IntentStatus> {
    return 'SUCCEEDED';
  }

  async refund(providerRef: string, _amount?: number): Promise<{ refundId: string }> {
    return { refundId: `re_mock_${providerRef}` };
  }

  async parseWebhook(rawBody: Buffer, _signature: string) {
    const payload = JSON.parse(rawBody.toString('utf8')) as {
      type?: string;
      providerRef?: string;
      metadata?: Record<string, string>;
    };
    return {
      type: payload.type ?? 'payment_intent.succeeded',
      providerRef: payload.providerRef ?? '',
      status: 'SUCCEEDED' as const,
      metadata: payload.metadata ?? {},
    };
  }
}

export class StripePaymentGateway implements PaymentGateway {
  async createIntent(input: CreateIntentInput): Promise<CreateIntentResult> {
    const client = stripe();
    const amount = Math.round(input.amount * 100);
    const paymentIntent = await client.paymentIntents.create({
      amount,
      currency: input.currency.toLowerCase(),
      payment_method_types: ['card'],
      metadata: input.metadata,
      description: `Zaya Events ${input.metadata.kind ?? 'payment'} · booking ${input.metadata.bookingId ?? ''}`.trim(),
    });
    if (!paymentIntent.client_secret) {
      throw new AppError(500, 'STRIPE_INTENT_FAILED', 'Stripe did not return a client secret');
    }
    return {
      providerRef: paymentIntent.id,
      clientSecret: paymentIntent.client_secret,
      mock: false,
    };
  }

  async intentStatus(providerRef: string): Promise<IntentStatus> {
    if (providerRef.startsWith('cs_')) {
      const session = await stripe().checkout.sessions.retrieve(providerRef);
      if (session.payment_status === 'paid') {
        return 'SUCCEEDED';
      }
      if (session.status === 'expired') {
        return 'FAILED';
      }
      return 'PROCESSING';
    }
    const paymentIntent = await stripe().paymentIntents.retrieve(providerRef);
    if (paymentIntent.status === 'succeeded') {
      return 'SUCCEEDED';
    }
    if (paymentIntent.status === 'canceled' || paymentIntent.status === 'requires_payment_method') {
      return 'FAILED';
    }
    return 'PROCESSING';
  }

  async refund(providerRef: string, amount?: number): Promise<{ refundId: string }> {
    let paymentIntent = providerRef;
    if (providerRef.startsWith('cs_')) {
      const session = await stripe().checkout.sessions.retrieve(providerRef);
      paymentIntent = typeof session.payment_intent === 'string' ? session.payment_intent : providerRef;
    }
    const refund = await stripe().refunds.create({
      payment_intent: paymentIntent,
      ...(amount !== undefined ? { amount: Math.round(amount * 100) } : {}),
    });
    return { refundId: refund.id };
  }

  async parseWebhook(rawBody: Buffer, signature: string) {
    if (!env.STRIPE_WEBHOOK_SECRET) {
      throw new AppError(500, 'STRIPE_MISCONFIGURED', 'STRIPE_WEBHOOK_SECRET must be set');
    }
    const event = stripe().webhooks.constructEvent(rawBody, signature, env.STRIPE_WEBHOOK_SECRET);
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session;
      const providerRef = session.id;
      const metadata: Record<string, string> = {};
      for (const [key, value] of Object.entries(session.metadata ?? {})) {
        if (typeof value === 'string') {
          metadata[key] = value;
        }
      }
      return { type: event.type, providerRef, status: 'SUCCEEDED' as const, metadata };
    }
    const object = event.data.object as Stripe.PaymentIntent;
    const status: 'SUCCEEDED' | 'FAILED' | 'PROCESSING' =
      event.type === 'payment_intent.succeeded'
        ? 'SUCCEEDED'
        : event.type === 'payment_intent.payment_failed'
          ? 'FAILED'
          : 'PROCESSING';
    const metadata: Record<string, string> = {};
    for (const [key, value] of Object.entries(object.metadata ?? {})) {
      if (typeof value === 'string') {
        metadata[key] = value;
      }
    }
    return {
      type: event.type as string,
      providerRef: object.id,
      status,
      metadata,
    };
  }
}

export const paymentGateway: PaymentGateway = env.STRIPE_SECRET_KEY
  ? new StripePaymentGateway()
  : new MockPaymentGateway();
