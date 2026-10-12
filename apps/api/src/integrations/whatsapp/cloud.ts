import { integrationsConfig } from '../config.js';
import { logger } from '../../lib/logger.js';
import { MockWhatsAppProvider } from './mock.js';
import type {
  WhatsAppDeliveryStatus,
  WhatsAppMediaSend,
  WhatsAppProvider,
  WhatsAppSendResult,
  WhatsAppTemplateSend,
} from './provider.js';

function digits(phone: string): string {
  return phone.replace(/[^\d]/g, '');
}

export class CloudWhatsAppProvider implements WhatsAppProvider {
  private readonly fallback = new MockWhatsAppProvider();

  private ready(): boolean {
    return Boolean(integrationsConfig.WHATSAPP_TOKEN && integrationsConfig.WHATSAPP_PHONE_NUMBER_ID);
  }

  private messagesUrl(): string {
    return `https://graph.facebook.com/${integrationsConfig.WHATSAPP_API_VERSION}/${integrationsConfig.WHATSAPP_PHONE_NUMBER_ID}/messages`;
  }

  private async post(payload: Record<string, unknown>): Promise<WhatsAppSendResult> {
    const response = await fetch(this.messagesUrl(), {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${integrationsConfig.WHATSAPP_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ messaging_product: 'whatsapp', ...payload }),
    });
    const json = (await response.json()) as { messages?: Array<{ id?: string }>; error?: { message?: string } };
    if (!response.ok) {
      throw new Error(json.error?.message ?? `WhatsApp send failed (${response.status})`);
    }
    return {
      messageId: json.messages?.[0]?.id ?? `wamid.${Date.now()}`,
      to: String(payload.to ?? ''),
      status: 'sent',
    };
  }

  async sendTemplate(input: WhatsAppTemplateSend): Promise<WhatsAppSendResult> {
    if (!this.ready()) {
      return this.fallback.sendTemplate(input);
    }
    try {
      return await this.post({
        to: digits(input.to),
        type: 'template',
        template: {
          name: input.templateName,
          language: { code: input.language ?? 'en' },
          components: input.bodyParams?.length
            ? [
                {
                  type: 'body',
                  parameters: input.bodyParams.map((text) => ({ type: 'text', text })),
                },
              ]
            : [],
        },
      });
    } catch (error) {
      logger.warn({ err: error }, 'WhatsApp template failed; sending text fallback');
      try {
        return await this.post({
          to: digits(input.to),
          type: 'text',
          text: { body: [input.templateName, ...(input.bodyParams ?? [])].join('\n') },
        });
      } catch (inner) {
        logger.warn({ err: inner }, 'WhatsApp text fallback failed; using mock');
        return this.fallback.sendTemplate(input);
      }
    }
  }

  async sendMedia(input: WhatsAppMediaSend): Promise<WhatsAppSendResult> {
    if (!this.ready()) {
      return this.fallback.sendMedia(input);
    }
    try {
      const type = input.mimeType?.startsWith('image/') ? 'image' : 'document';
      return await this.post({
        to: digits(input.to),
        type,
        [type]: { link: input.mediaUrl, caption: input.caption },
      });
    } catch (error) {
      logger.warn({ err: error }, 'WhatsApp media failed');
      return this.fallback.sendMedia(input);
    }
  }

  async deliveryStatus(messageId: string): Promise<WhatsAppDeliveryStatus> {
    return this.fallback.deliveryStatus(messageId);
  }
}
