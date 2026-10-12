import { ConversationType, MessageType } from '@prisma/client';
import { z } from 'zod';
import { paginationQuerySchema } from '../../lib/common.js';

export const conversationListQuery = paginationQuerySchema;
export const messageListQuery = paginationQuerySchema;

export const conversationCreateSchema = z.object({
  participantId: z.string().uuid(),
  type: z.nativeEnum(ConversationType).default(ConversationType.CUSTOMER_VENDOR),
  bookingId: z.string().uuid().optional(),
});

export const messageCreateSchema = z.object({
  type: z.nativeEnum(MessageType).default(MessageType.TEXT),
  body: z.string().min(1).max(5000),
  attachments: z
    .array(
      z.object({
        key: z.string().min(1),
        url: z.string().min(1),
        contentType: z.string().min(1),
      }),
    )
    .optional()
    .default([]),
});
