import { randomUUID } from 'node:crypto';
import Stripe from 'stripe';
import { env } from '../../config/env.js';
import { AppError } from '../../lib/errors.js';
import type { CreateIntentInput, CreateIntentResult, PaymentGateway } from './payment.provider.js';

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
      checkoutUrl: undefined,
      mock: true,
    };
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
    const session = await client.checkout.sessions.create({
      mode: 'payment',
      success_url: `${env.API_URL}/api/v1/payments/complete?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${env.API_URL}/api/v1/payments/complete?canceled=1`,
      metadata: input.metadata,
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency: input.currency.toLowerCase(),
            unit_amount: amount,
            product_data: {
              name: `Zaya Events ${input.metadata.kind ?? 'payment'}`,
              description: `Booking ${input.metadata.bookingId ?? ''}`.trim(),
            },
          },
        },
      ],
      payment_intent_data: { metadata: input.metadata },
    });
    return {
      providerRef: session.id,
      clientSecret: session.client_secret ?? session.id,
      checkoutUrl: session.url ?? undefined,
      mock: false,
    };
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
