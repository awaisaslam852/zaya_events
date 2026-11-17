export type CreateIntentInput = {
  amount: number;
  currency: string;
  metadata: Record<string, string>;
};

export type CreateIntentResult = {
  providerRef: string;
  clientSecret: string;
  mock: boolean;
};

export type IntentStatus = 'SUCCEEDED' | 'FAILED' | 'PROCESSING';

export interface PaymentGateway {
  createIntent(input: CreateIntentInput): Promise<CreateIntentResult>;
  intentStatus(providerRef: string): Promise<IntentStatus>;
  refund(providerRef: string, amount?: number): Promise<{ refundId: string }>;
  parseWebhook(rawBody: Buffer, signature: string): Promise<{
    type: string;
    providerRef: string;
    status: IntentStatus;
    metadata: Record<string, string>;
  }>;
}
