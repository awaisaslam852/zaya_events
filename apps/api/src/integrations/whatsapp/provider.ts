export type WhatsAppTemplateSend = {
  to: string;
  templateName: string;
  language?: string;
  bodyParams?: string[];
};

export type WhatsAppMediaSend = {
  to: string;
  mediaUrl: string;
  caption?: string;
  mimeType?: string;
};

export type WhatsAppSendResult = {
  messageId: string;
  to: string;
  status: 'queued' | 'sent' | 'delivered' | 'read' | 'failed';
};

export type WhatsAppDeliveryStatus = {
  messageId: string;
  status: 'queued' | 'sent' | 'delivered' | 'read' | 'failed';
  timestamp: string;
};

export interface WhatsAppProvider {
  sendTemplate(input: WhatsAppTemplateSend): Promise<WhatsAppSendResult>;
  sendMedia(input: WhatsAppMediaSend): Promise<WhatsAppSendResult>;
  deliveryStatus(messageId: string): Promise<WhatsAppDeliveryStatus>;
}
