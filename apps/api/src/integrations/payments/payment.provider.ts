export type CreateIntentInput = {
  amount: number;
  currency: string;
  metadata: Record<string, string>;
};

export type CreateIntentResult = {
  providerRef: string;
  clientSecret: string;
  checkoutUrl?: string;
  mock: boolean;
};

export interface PaymentGateway {
  createIntent(input: CreateIntentInput): Promise<CreateIntentResult>;
  refund(providerRef: string, amount?: number): Promise<{ refundId: string }>;
  parseWebhook(rawBody: Buffer, signature: string): Promise<{
    type: string;
    providerRef: string;
    status: 'SUCCEEDED' | 'FAILED' | 'PROCESSING';
    metadata: Record<string, string>;
  }>;
}
