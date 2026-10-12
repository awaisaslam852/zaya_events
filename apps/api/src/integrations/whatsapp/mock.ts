import { randomUUID } from 'node:crypto';
import { logger } from '../../lib/logger.js';
import type {
  WhatsAppDeliveryStatus,
  WhatsAppMediaSend,
  WhatsAppProvider,
  WhatsAppSendResult,
  WhatsAppTemplateSend,
} from './provider.js';

const statuses = new Map<string, WhatsAppDeliveryStatus>();

export class MockWhatsAppProvider implements WhatsAppProvider {
  async sendTemplate(input: WhatsAppTemplateSend): Promise<WhatsAppSendResult> {
    const messageId = `wamid.mock.${randomUUID()}`;
    const result: WhatsAppSendResult = { messageId, to: input.to, status: 'sent' };
    statuses.set(messageId, {
      messageId,
      status: 'delivered',
      timestamp: new Date().toISOString(),
    });
    logger.info({ to: input.to, template: input.templateName, messageId }, 'WhatsApp mock template queued');
    return result;
  }

  async sendMedia(input: WhatsAppMediaSend): Promise<WhatsAppSendResult> {
    const messageId = `wamid.mock.${randomUUID()}`;
    statuses.set(messageId, {
      messageId,
      status: 'sent',
      timestamp: new Date().toISOString(),
    });
    logger.info({ to: input.to, mediaUrl: input.mediaUrl, messageId }, 'WhatsApp mock media queued');
    return { messageId, to: input.to, status: 'sent' };
  }

  async deliveryStatus(messageId: string): Promise<WhatsAppDeliveryStatus> {
    return (
      statuses.get(messageId) ?? {
        messageId,
        status: 'failed',
        timestamp: new Date().toISOString(),
      }
    );
  }
}
